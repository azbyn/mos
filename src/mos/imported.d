module mos.imported;

public import mos.objects;
public import mos.stdlib;

//attributes:
enum mosexport; // anything that should be shown in mos
enum mosstatic; // static function
enum mosget; // property getter
enum mosset; // property setter
enum mosmodule; // module declaration, must be abstract class
enum mostrace; // for functions with __FILE__ __LINE__

/*
  TODO Rewrite this
  * Last trailing underscore (ie fun_) gets removed,
  usefull for things like assert

  * Because __traits(getProtection) doesn't properly work
  * Everything that should be shown in mos must have @mosexport
  * Exported functions that use 'string file = __FILE__, size_t line = __LINE) must have @mostrace
  * All modules that contain @mosexport must have MOSModule!(name.of.the.module);
  * All modules that contain MOSModule must be added to mos.imported.modules
  * All builtin types must contain mixin MOSType!"name to be shown in mos"; or @mosmodule
  * All things with @mosexport must be static
  * init gets automatically called (use this instead of 'static this')
  eg:

lib/foo.a.d:
    module lib.foo.a;
    import mos.objects;
    MOSModule!(lib.foo.a);

    @mosexport struct X {
        mixin MOSType!"Foo";
    static:
        @mosexport {
            mosstring toString(Pos p, Env e, X x) { return "foo"; }
            @mosstatic @mosget mosint Prop() { return 2; }
        }
    }
lib/foo.b.d:
    module lib.foo.b;
    import mos.objects;
    MOSModule!(lib.foo.b);

    @mosexport void function_() {}
    @mosexport mosfloat Const() { return 6.28318; }
    void init() {}

lib/package.d:
    module lib;
    public import lib.foo.a;
    public import lib.foo.b;

    enum modules = ["lib.foo.a", "lib.foo.b"];

mos/imported.d:
    ...
    import lib;
    enum modules = mos.objects.modules ~ ... ~ lib.modules;
    ...
 */

//because of cyclic dependencies we must add all modules that use MOSModule here
enum modules = mos.objects.modules ~ mos.stdlib.modules;
mixin template MOSType(mosstring name) {
    static __gshared TypeMeta typeMeta;
    static enum mosstring type = name;
}

mixin template MOSModule(alias Mod) {
    //adding this here stops the compiler from complaining about
    // 'Deprecation: module X is not accessible here'
struct _MosModuleHelper(alias Mod) {
    import mos.types;
    import stdd.array;
    import stdd.format;
    import stdd.typecons;
    import stdd.traits;

    /*string cutStart(string s, string ptrn) {
        auto len = ptrn.length;
        if (s[0..len] == ptrn) return s[len..$];
        return null;
        }*/
    enum PreInfo {
        None,
        PosOnly,
        PosEnv,
    }

    struct FuncData {
        FuncType ft;
        bool isTrace;
    }
    enum SymbolType {
        NotExported, Module, Type, Function,
    }
    struct SymbolData {
        SymbolType st;
        bool isStatic;
    }
    alias Objs = Obj[mosstring];
static:

    SymbolData symbolData(alias Sym, bool insideModule)() {
        enum isStatic = hasUDA!(Sym, mosstatic) || insideModule;
        SymbolType st() pure {
            static if (__traits(isStaticFunction, Sym)) {
                return hasUDA!(Sym, mosexport) ? SymbolType.Function : SymbolType.NotExported;
            }
            else static if (isType!Sym) {
                return hasUDA!(Sym, mosexport) ?
                    (hasUDA!(Sym, mosmodule) ?
                     SymbolType.Module :
                     SymbolType.Type) :
                    SymbolType.NotExported;
            }
            else return SymbolType.NotExported;
        }
        return SymbolData(st(), isStatic);
    }
    FuncData funcData(alias T, string fun)() {
        mixin(format!"alias x = T.%s;"(fun));
        static if (hasUDA!(x, mosget))
            enum ft = FuncType.Getter;
        else static if (hasUDA!(x, mosset))
            enum ft = FuncType.Setter;
        else
            enum ft = FuncType.Default;
        enum isTrace = hasUDA!(x, mostrace);

        return FuncData(ft, isTrace);
    }
    /*
    static SymbolType symbolType(T)() {
        return SymbolType.NotExported;
        }*/

    Obj toObj(T)(T t) {
        //dfmt off
        static if (is(T==Obj)) return t;
        //else static if (is(T==enum)) return objInt(cast(tsint)t);
        else static if (is(T==mosint)) return obj!Int(t);
        else static if (is(T==bool)) return obj!Bool(t);
        else static if (is(T==mosfloat)) return obj!Float(t);
        else static if (is(T==mosstring)) return obj!String(t);
        //else static if (is(T==Obj[])) return objList(t);
        else static if (is(T==Obj[Obj])) return obj!Map(t);
        else return new Obj(t);
        //dfmt on
    }
    void addSymbol(SymbolData sd, alias T, string name)(ref Objs statics) {
        Objs _;
        addSymbol!(sd, T, name)(statics, _);
    }
    void addSymbol(SymbolData sd, alias T, string name)(ref Objs statics, ref Objs instance) {
        enum mosName = (name.back() == '_' ? name[0..$-1] : name).to!mosstring;
        static if (sd.st == SymbolType.Type) {
            static if (name!="UserDefined")
                addType!(mosName, mixin("T."~name))(statics);
        }
        else static if (sd.st == SymbolType.Module) {
            addModule!(mosName, mixin("T."~name))(statics);
        }
        else static if (sd.st == SymbolType.Function) {
            enum fd = funcData!(T, name);
            auto fun = getFunction!(T, name, fd, sd.isStatic);
            static if (sd.isStatic) {
                assignFuncType!(fd.ft)(statics, mosName, fun);
            }
            else {
                assignMemberFuncType!(fd.ft)(instance, mosName, fun);
            }
        }
    }
    void addModule(mosstring name, alias M)(ref Objs objs) {
        Module res = Module(name);
        static foreach (member; __traits(derivedMembers, M)) {
            static if (member == "init") {
                M.init();
            }
            else {{
                enum sd = symbolData!(mixin("M."~ member), true);
                addSymbol!(sd, M, member)(res.members);
            }}
        }
        objs[name] = new Obj(res);
    }
    void addType(string name, alias T)(ref Objs objs) {
        TypeMeta type = makeTypeMeta!T;
        //pragma(msg, format!"\t<type %s>"(name));
        static foreach (member; __traits(derivedMembers, T)) {{
            static if (member == "ctor") {
                enum sd = symbolData!(mixin("T."~ member), false);
                static if (sd.st == SymbolType.Function) {
                    enum fd = funcData!(T, "ctor");
                    //static assert(st == SymbolType.Function);
                    static assert(!sd.isStatic);
                    type.ctor = obj!BIMethodMaker(getFunction!(T, "ctor", fd, sd.isStatic));
                }
            }
            else static if (member == "init") {
                T.init();
            }
            else static if (member != "type") {
                enum sd = symbolData!(mixin("T."~ member), false);
                addSymbol!(sd, T, member)(type.statics, type.instance);
            }
            /+
        else static if (member != "type")/*m != "typeMeta" && m != "__ctor")*/ {
        enum data = getFuncData!member;
            Obj o;
            if (getFun!(T, m)(o))
                assignFuncType!(data.ft)(type.members, data.name, o);
        }+/
        }}
        T.typeMeta = type;
        if (!is(T == TypeMeta))
            objs[name] = new Obj(type);
    }

    Obj[mosstring] get() {
        Obj[mosstring] objs;
        static foreach (mem; __traits(derivedMembers, Mod)) {{
            static if (mem != "_MosModuleHelper"&&mem != "_mosModuleInit") {
                static if (__traits(compiles, __traits(getProtection, __traits(getMember, Mod, mem)))) {
                    static if (__traits(getProtection, __traits(getMember, Mod, mem)) == "public") {
                        mixin(format!"alias X = Mod.%s;"(mem));
                        enum sd = symbolData!(X, true);
                        /*static if (st == SymbolType.Type)
                          data.types ~= mem;*/
                        addSymbol!(sd, Mod, mem)(objs);
                    }
                }
            }
        }}
        return objs;
    }
    alias Fun = Obj function(Pos, Env, Obj[]);
    //alias Method = Fun delegate(Obj);
    auto getFunction(alias T, string fun, FuncData fd, bool isStatic)() {
        Fun[int] val;
        static foreach (o; __traits(getOverloads, T, fun)) {{
            immutable f = getFunImpl!(o, fd.isTrace, fullyQualifiedName!T ~ "."~ fun);
            //pragma(msg, format!"added %s: %s"(fun, typeid(f)));

            assert(f.i !in val, format!"@%s please only define 1 overload per arg count"(fun));
            val[f.i] = f.val;
        }}
        assert(val.length != 0, format!"no valid overloads found for %s.%s"(fullyQualifiedName!T, fun));
        static if (isStatic) {
            return obj!BIOverloads(val);
        }
        else {
            //return obj!BIMethodMaker(
            return (Obj o) => obj!BIMethodOverloads(o, val);
        }
    }

    auto getFunImpl(alias fun, bool isTrace, string name)() {
        struct Res(T) {
            int i;
            T val;
        }

        enum isVoid = is(ReturnType!fun == void);
        //string res = format!"(Pos p, Env e, Obj[] a) { assert(a.length == %s); }";
        static if (Parameters!fun.length > 0 && is(Parameters!fun[0] == Pos)) {
            static if (Parameters!fun.length >= 2 && is(Parameters!fun[1] == Env)) {
                enum funCall = getFunCall!(fun, PreInfo.PosEnv, isTrace);
            }
            else {
                enum funCall = getFunCall!(fun, PreInfo.PosOnly, isTrace);
            }
        }
        else {
            enum funCall = getFunCall!(fun, PreInfo.None, isTrace);
        }
        //pragma(msg, format!"'%s' len = %s"(funCall.val, funCall.len));
        return Res!(Obj function(Pos, Env, Obj[]))(funCall.len, (Pos p, Env e, Obj[] args) {
            static if (funCall.check !is null){
                funCall.check(p, args.length);
            }
            //writefln("::l", funCall.len, args.length);

            static if (is(ReturnType!fun == void)) {
                mixin(funCall.val ~ ";");
                return nil;
            }
            else {
                //import com.log;
                //tslog!"%s: %s"(name, funCall.val);
                //please_break();
                return toObj(mixin(funCall.val));
            }
        });
    }

    auto getFunCall(alias fun, PreInfo preInfo, bool isTrace)() {
        struct Res {
            int len;
            string val;
            void function(Pos, size_t) check;
        }
        string res = "fun(";
        static if (preInfo == PreInfo.None) {
            enum offset = 0;
        }
        else static if (preInfo == PreInfo.PosOnly) {
            enum offset = 1;
            res ~= "p, ";
        }
        else {
            enum offset = 2;
            res ~= "p, e, ";
        }
        enum begOffset = isTrace ? 2 : 0;
        enum int len = Parameters!fun.length - offset - begOffset;
        static foreach (i, p; Parameters!fun[offset .. $-begOffset]) {
            static if (is(p==Obj[])) {
                assert(len == i +1, format!"can't have other args after Obj[] (%d, %d)"(len, i+1));
                res ~= format!"args[%d..$])"(i);
                return Res(-1, res, (Pos p, size_t len) {
                    if (len < i)
                        throw new RuntimeException(p, format!"Expected at least %s arguments, got %s"(i, len));
                });
            }
            else {
                res ~= format!"args[%d].get!(Parameters!fun[%d])(p),"(i, i + offset);
            }
        }
        if (len != 0 && is(Parameters!fun[Parameters!fun.length - 1] == Obj[])) {
            assert(0, format!"something went wrong %s, %s"(len, offset));
        }
        else {
            return Res(len, res ~ ")", null);
        }
    }
}

    void _mosModuleInit() {
        import com.log;
        import stdd.traits;
        //moslog("()init: "~fullyQualifiedName!Mod);
        stdlib.append(_MosModuleHelper!Mod.get());
    }
}

__gshared private {
    Lib _stdlib;
    Obj _nil;
}


import mos.ir.lib;
//import mos.objects.obj : Obj;
//import mos.objects.nil : Nil;
@property Obj nil() { return _nil; }

@property Lib stdlib() { return _stdlib; }
static this() {
    import com.log;
    moslog("<Imported init()>");
    _stdlib = new Lib(null);
    static foreach (m; modules) {
        mixin(m~"._mosModuleInit();");
    }
    _nil = new Obj(Nil());
    moslog("</Imported init()>");

}
