module ts.imported;

public import ts.objects;
public import ts.stdlib;

//attributes:
enum tsexport; // anything that should be shown in ts
enum tsstatic; // static function
enum tsget; // property getter
enum tsset; // property setter
enum tsmodule; // module declaration, must be abstract class
enum tstrace; // for functions with __FILE__ __LINE__

/*
  TODO Rewrite htis
  * Last trailing underscore (ie fun_) gets removed,
  usefull for things like assert

  * Because __traits(getProtection) doesn't properly work 

  * Classes and structs shouldn't have @tsexport as it does nothing,
  instead it should be included in an immutable array 'types'
  and added to ts.objects.obj.types.
  Modules that contain @tsexports should be added below
  as strings.
  eg:

ts.foo.a.d:
    enum types = ["Foo", "Foo.Bar", "Baz"];

ts.foo.package.d:
    public import ts.foo.a;
    public import ts.foo.b;
    import ts.builtin;

    enum modules = ["ts.foo.a", "ts.foo.b"];
    enum types = getTypes!(modules);

ts.objects.d:
    enum types = ts.objects.types ~ ... ~ ts.foo.types;
    enum modules = ... ~ ts.foo.modules;
 */
/*
static import ts.objects.nil;
static import ts.objects.function_;
static import ts.objects.closure;
static import ts.objects.bi_function;
static import ts.objects.bi_overloads;
static import ts.objects.float_;
static import ts.objects.int_;
static import ts.objects.bool_;
static import ts.objects.string_;
static import ts.objects.list;
static import ts.objects.tuple;
static import ts.objects.dict;
static import ts.objects.property;
static import ts.objects.range;
static import ts.objects.type_meta;
static import ts.objects.module_;
static import ts.objects.user_defined;
static import ts.stdlib.io;
static import ts.stdlib.misc;
static import ts.stdlib.math;
*/

//because of cyclic dependencies we must add all modules that use TSModule here
enum modules = ts.objects.modules ~ ts.stdlib.modules;
/*@property auto types() {
    string[] res;
    static foreach (m; modules)
        res ~= mixin(m ~ ".moduleData.types");
    return res;
    }*/
mixin template TSType(tsstring name) {
    static __gshared TypeMeta typeMeta;
    static enum tsstring type = name;
}

mixin template TSModule(alias Mod) {
    //adding this here stops the compiler from complaining about
    // 'Deprecation: module X is not accessible here'
struct _TsModuleHelper(alias Mod) {
    import ts.types;
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
    alias Objs = Obj[tsstring];
static:

    SymbolData symbolData(alias Sym, bool insideModule)() {
        enum isStatic = hasUDA!(Sym, tsstatic) || insideModule;
        SymbolType st() pure {
            static if (__traits(isStaticFunction, Sym)) {
                return hasUDA!(Sym, tsexport) ? SymbolType.Function : SymbolType.NotExported;
            }
            else static if (isType!Sym) {
                return hasUDA!(Sym, tsexport) ?
                    (hasUDA!(Sym, tsmodule) ?
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
        static if (hasUDA!(x, tsget))
            enum ft = FuncType.Getter;
        else static if (hasUDA!(x, tsset))
            enum ft = FuncType.Setter;
        else
            enum ft = FuncType.Default;
        enum isTrace = hasUDA!(x, tstrace);

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
        else static if (is(T==tsint)) return obj!Int(t);
        else static if (is(T==bool)) return obj!Bool(t);
        else static if (is(T==tsfloat)) return obj!Float(t);
        else static if (is(T==tsstring)) return obj!String(t);
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
        enum tsName = (name.back() == '_' ? name[0..$-1] : name).to!tsstring;
        static if (sd.st == SymbolType.Type) {
            static if (name!="UserDefined")
                addType!(tsName, mixin("T."~name))(statics);
        }
        else static if (sd.st == SymbolType.Module) {
            addModule!(tsName, mixin("T."~name))(statics);
        }
        else static if (sd.st == SymbolType.Function) {
            enum fd = funcData!(T, name);
            auto fun = getFunction!(T, name, fd, sd.isStatic);
            static if (sd.isStatic) {
                assignFuncType!(fd.ft)(statics, tsName, fun);
            }
            else {
                assignMemberFuncType!(fd.ft)(instance, tsName, fun);
            }
        }
    }
    void addModule(tsstring name, alias M)(ref Objs objs) {
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
                    type.ctor = obj!MethodMaker(getFunction!(T, "ctor", fd, sd.isStatic));
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

    Obj[tsstring] get() {
        Obj[tsstring] objs;
        static foreach (mem; __traits(derivedMembers, Mod)) {{
            static if (mem != "_TsModuleHelper"&&mem != "_tsModuleInit") {
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
            immutable f = getFunImpl!(o, fd.isTrace);
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

    auto getFunImpl(alias fun, bool isTrace)() {
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

    void _tsModuleInit() {
        import com.log;
        import stdd.traits;
        //tslog("()init: "~fullyQualifiedName!Mod);
        stdlib.append(_TsModuleHelper!Mod.get());
    }
}

__gshared private {
    Lib _stdlib;
    Obj _nil;
}


import ts.ir.lib;
//import ts.objects.obj : Obj;
//import ts.objects.nil : Nil;
@property Obj nil() { return _nil; }

@property Lib stdlib() { return _stdlib; }
static this() {
    import com.log;
    tslog("<Imported init()>");
    _stdlib = new Lib(null);
    static foreach (m; modules) {
        mixin(m~"._tsModuleInit();");
    }
    _nil = new Obj(Nil());
    tslog("</Imported init()>");

}
