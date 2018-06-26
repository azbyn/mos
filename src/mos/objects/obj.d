module mos.objects.obj;

import mos.objects;

import mos.misc;
import mos.ir.block;
import stdd.format;

public import mos.ast.token;
public import mos.runtime.env;
public import mos.imported;
public import mos.misc : FuncType;
public import mos.objects.type_meta;
public import mos.types;
public import mos.stdlib;

//stop the compiler from complaining
public import stdd.format : format;
public import stdd.conv : to;


import stdd.variant : VariantN;

class RuntimeException : MOSException {
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        super(pos, msg, file, line);
    }
}
enum objSize = (void*).sizeof * 4;
/*version (D_LP64) { 
    enum objSize = 32;
}
else {
    enum objSize = 16;
    }*/

import com.log;
Obj obj(T, A...)(A args, string file = __FILE__, size_t line = __LINE__) {
    static if (is(T==TypeMeta)) {
        return new Obj(new T(args));
    }
    else {
        return new Obj(T(args));
    }
}
extern(C) void please_break() {}
class Obj {
    /*
    private static string genVal() {
        string r = "Algebraic!(";
        static foreach (t; types)
            r ~= t ~ ",";
        return r ~ ") val;";
        }*/
    TypeMeta typeMeta;
    @property mosstring typestr() { return typeMeta.name; }
    VariantN!objSize val;
    //mixin(genVal());
    /*
    this(mosstring type, mosstring s) {
        this.val = String(s);
        }*/
    import stdd.traits : isSomeString, fullyQualifiedName;
    this(T)(T val) if (!is(T == UserDefined)) {
         this(T.typeMeta, val);
    }
    /*
    this(TypeMeta* tm, Obj[mosstring] vars) {
        this(tm, UserDefined(vars));
        }*/
    this(T)(TypeMeta typeMeta, T val) {
        this.typeMeta = typeMeta;
        //assert(typeMeta);
        //moslog!"<<<NEW '%s'"(typeMeta.name);
        this.val = val;
    }

    override const nothrow @safe size_t toHash() {
        return val.toHash();
    }
    private static auto getName(T)() {
        static if (__traits(hasMember, T, "type"))
            return T.type;
        else return fullyQualifiedName!T;
    }
    T* getPtr(T)(Pos pos) {
        auto a = val.peek!T;
        if (a is null)
            throw new RuntimeException(pos, format!"Expected type %s, got %s"(getName!T, typestr));
        return a;
    }

    T get(T)(Pos pos, string file = __FILE__, size_t line = __LINE__) {
        import stdd.traits;
        static if (is(T==Obj)) return this;
        else static if (is(T==mosint)) return get!Int(pos).val;
        else static if (is(T==bool)) return get!Bool(pos).val;
        else static if (is(T==mosfloat)) return get!Float(pos).val;
        else static if (is(T==mosstring)) return get!String(pos).val;
        else static if (isPointer!T) {
            return getPtr!(PointerTarget!T)(pos);
        }
        else {
            auto a = val.peek!T;
            if (a !is null)
                return *a;
            please_break();
            throw new RuntimeException(pos, format!"Expected type %s, got %s"(getName!T, typestr), file, line);
        }
    }
    bool isNil() {
        return val.peek!(Nil) !is null;
    }
    bool is_(T)() {
        return val.peek!(T) !is null;
    }
    T* peek(T)() {
        return val.peek!(T);
    }

    Obj callThis(Pos p, Obj this_) {
        return this.visitO!(
            (BIMethodMaker bimm) => bimm.callThis(this_),
            (MethodClosureMaker mm) => mm.callThis(this_),
            (MethodFunctionMaker mm) => mm.callThis(this_),
            () => throwRtrn!(Obj, RuntimeException)(p, format!"can't call this on %s"(typestr))
            );
    }
    override string toString() {
        throw new Exception("please use toStr", __FILE__, __LINE__);
    }
    mosstring toStr(Pos p, Env e) {
        return memberCallCast!mosstring("toString", p, e);
    }

    bool toBool(Pos p, Env e) {
        return memberCallCast!bool("toBool", p, e);
    }
    bool equals(Pos p, Env e, Obj other) {
        return memberCallCast!bool("opEquals", p, e, other);
    }
    mosint cmp(Pos p, Env e, Obj other) {
        auto f = typeMeta.tryMember("opCmp");
        if (f !is null) {
            auto r = f.callThis(p, this).call(p, e, other);
            if (!r.isNil())
                return r.get!mosint(p);
        }
        f = other.typeMeta.tryMember("opCmpR");
        if (f !is null) {
            auto r = f.callThis(p, this).call(p, e, other);
            if (!r.isNil())
                return -r.get!mosint(p);
        }
        throw new TypeException(p, format!"Binary 'opCmp', not overloaded for type %s"(typestr));
    }
    Obj binary(Pos p, Env e, mosstring op, Obj other) {
        auto f = typeMeta.tryMember(op);
        if (f !is null) {
            auto r = f.callThis(p, this).call(p, e, other);
            if (!r.isNil())
                return r;
        }
        f = other.typeMeta.tryMember(op~"R");
        if (f !is null) {
            auto r = f.callThis(p, other).call(p, e, this);
            if (!r.isNil())
                return r;
        }
        throw new TypeException(p, format!"Binary '%s', not overloaded for type %s"(op, typestr));
    }
    Obj binary(mosstring op)(Pos pos, Env env, Obj other) {
        enum name = symbolicToTT(op).binaryFunctionName;
        static assert(name.length > 0);
        return binary(pos, env, name, other);
    }

    Obj call(Pos p, Env e, Obj[] args...) {
        foreach (ref a; args) {
            Property* prop = a.val.peek!Property;
            if (prop !is null) a = prop.callGet(p, e);
        }
        //dfmt off
        return this.visitO!(
            (StaticFunction f) => f(p, e, args),
            (MethodFunction f) => f(p, e, args),
            (BIFunction f) => f(p, e, args),
            (MethodClosure f) => f(p, e, args),
            (StaticClosure f) => f(p, e, args),
            (BIOverloads f) => f(p, e, args),
            (BIClosure f) => f(p, e, args),
            (BIMethodOverloads f) => f(p, e, args),
            (TypeMeta t) => t.construct(p, e, args),
            //() => member(p, "opCall").call(p, e, args)
            () => throwRtrn!(Obj, RuntimeException)(p, format!"Expected function, found %s"(typestr))
        );
        //dfmt on
    }
    Obj getStatic(Pos p, Env e, mosstring m) {
        return typeMeta.getStatic(p, e, m);
    }
    Obj setStatic(Pos p, Env e, mosstring m, Obj val) {
        return typeMeta.setStatic(p, e, m, val);
    }

    Obj getMember(Pos p, Env e, mosstring m) {
        return member(p, e, m);
    }

    Obj setMember(Pos p, Env e, mosstring m, Obj val) {
        return typeMeta.setMember(this, p, e, m, val);
    }
    Obj member(Pos p, Env e, mosstring m) {
        return typeMeta.getMember(this, p, e, m);
//return e.getMember(p, this /* type*/, m);
    }
    Obj memberCall(Pos p, Env e, mosstring m, Obj[] args...) {
        return member(p, e, m).call(p,e, args);
    }
    private T memberCallCast(T)(mosstring m, Pos p, Env e, Obj[] args...) {
        return memberCall(p, e, m, args).get!T(p);
    }

}

auto visitO(Handler...)(Obj o) if (Handler.length > 0) {
    import stdd.traits;
    static foreach (h; Handler) {{
        static assert(isSomeFunction!h);

        alias Params = Parameters!h;
        static if (Params.length == 0) {
            return h();
        }
        else {
            static assert(Params.length == 1);
            alias P = Params[0];
            static if (isPointer!P) {
                if (P p = o.val.peek!(PointerTarget!P)) return h(p);
            } else {
                if (P* p = o.val.peek!P) return h(*p);
            }
        }
    }}
    assert(0, "please add a visit with no parameters");
}
auto visitO(Handler...)(Obj* o) if (Handler.length > 0) {
    return visitO!(Handler)(*o);
}
/*
R visitR(R, Handler...)(Obj o) if (Handler.length > 0) {
    return visitO!(Handler)(o);
    }*/

unittest {
    import stdd.stdio;

    Obj o = objString("s");
    writeln(o.toString);
    writeln(Nil.toString);
    assert(Nil.toString() == "nil");
}

