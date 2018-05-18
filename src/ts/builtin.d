module ts.builtin;

import ts.objects;
import ts.ast.token;
import ts.runtime.env;
import ts.ir.lib;
import ts.type_table;
import ts.stdlib;
import com.log;
import stdd.format;
import stdd.traits;
import stdd.meta;
import stdd.typecons;
import stdd.array;
import stdd.conv : to;

__gshared private {
    TypeTable _typeTable;
    Lib _stdlib;
    Obj _nil;
}
Obj nil() {
    return _nil;
}

TypeTable typeTable() {
    return _typeTable;
}

Lib stdlib() {
    return _stdlib;
}


Obj toObj(T)(T t) {
    //dfmt off
    static if (is(T==Obj)) return t;
    else static if (is(T==tsint)) return objInt(t);
    else static if (is(T==bool)) return objBool(t);
    else static if (is(T==tsfloat)) return objFloat(t);
    else static if (is(T==tsstring)) return objString(t);
    else static if (is(T==Obj[])) return objList(t);
    else static if (is(T==Obj[Obj])) return objMap(t);
    else return new Obj(t);
    //dfmt on
}
private:

auto getFunCall(alias fun, bool hasPos)() {
    struct Res {
        int len;
        string val;
        void function(Pos, size_t) check;
    }
    
    enum offset = hasPos ? 2 : 0;
    string res = "fun(";
    static if (hasPos)
        res ~= "p, e, ";
    enum int len = Parameters!fun.length - offset;
    static foreach (i, p; Parameters!fun[offset .. $]) {
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
auto getFunImpl(alias fun)() {
    struct Res(T) {
        int i;
        T val;
    }

    enum isVoid = is(ReturnType!fun == void);
    //string res = format!"(Pos p, Env e, Obj[] a) { assert(a.length == %s); }";
    static if (Parameters!fun.length > 0 && is(Parameters!fun[0] == Pos)) {
        static assert(Parameters!fun.length >= 2 && is(Parameters!fun[1] == Env));
        enum funCall = getFunCall!(fun, true);
    }
    else {
        enum funCall = getFunCall!(fun, false);
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

Obj getFun(alias T, string fun)() {
    Obj function(Pos, Env, Obj[])[int] val;
    static foreach (o; __traits(getOverloads, T, fun)) {{
        static if (__traits(getProtection, o) == "public" &&
                   __traits(isStaticFunction, o)) {
            enum f = getFunImpl!(o);
            //pragma(msg, format!"added %s: %s"(fun, typeid(f)));

            assert(f.i !in val, format!"@%s please only define 1 overload per arg count"(fun));
            val[f.i] = f.val;
        }
    }}
    return objBIOverloads(val);
}
static this() {
    _nil = new Obj(Nil());

    Obj defaultToString(T)() {
        return objBIFunction((Pos p, Env e, Obj[] a) => objString(T.type()));
    }
    Obj defaultToBool = objBIFunction((Pos p, Env e, Obj[] a)=>objBool(true));
    Obj defaultOpEquals = objBIFunction((Pos p, Env e, Obj[] a)=>objBool(false));

    _typeTable = new TypeTable();
    Obj[tsstring] objs;

    static foreach (t; ts.objects.obj.types) {{
        mixin(format!"alias T = %s;"(t));
        Type type = Type();
        type.members["toString"] = defaultToString!T();
        type.members["toBool"] = defaultToBool;
        type.members["opEquals"] = defaultOpEquals;
        //pragma(msg, format!"\t<type %s>"(t));
        static foreach (m; __traits(derivedMembers, T)) {
            static if (m == "ctor") {
                type.ctor = getFun!(T, m);
                objs[T.type()] = objBIFunction(
                    (Pos p, Env e, Obj[] a) {
                        import stdd.array;
                        auto v = new Obj(T());
                        Obj[] args = uninitializedArray!(Obj[])(a.length + 1);
                        args[0] = v;
                        args[1..$] = a[];
                        typeTable.tryCtor!T.call(p, e, args);
                        return v;
                    });
            }
            else static if (m != "type") {
                type.members[m] = getFun!(T, m);
            }
            /*
            else static if (m == "toString") {
                type.members[m] = getFun!(T, m);
            }*/
        }
        _typeTable.add!T(type);
    }}
    //_typeTable.print();
    static foreach (f; __traits(allMembers, ts.stdlib)) {
        if (f[0..2] != "__") {
            //for defining functions such as assert
            static if (f.back() == '_')
                enum name = f[0..$-1];
            else
                enum name = f;
            objs[name.to!tsstring] = getFun!(ts.stdlib, f);
        }
    }
    _stdlib = new Lib(objs);
    __init();
}
