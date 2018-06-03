module ts.objects.obj;

import ts.objects;

import ts.misc;
import ts.type_table;
import ts.ir.block;
import stdd.format;

public import ts.ast.token;
public import ts.runtime.env;
public import ts.builtin;
public import ts.misc : FuncType;
import ts.stdlib;

public import stdd.variant;

enum types = [
    "Nil", "Function", "Closure", "BIFunction", "BIOverloads", "Int", "Float",
    "Bool", "String", "List", "ListIter", "Dict", "DictIter", "Range", "Tuple_",
    "TupleIter", "Property", "Type_"
    ];


class RuntimeException : TSException {
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        super(pos, msg, file, line);
    }
}

class Obj {
    private static string genVal() {
        string r = "Algebraic!(";
        static foreach (t; types)
            r ~= t ~ ",";
        return r ~ ") val;";
    }

    mixin(genVal());
    this(tsstring s) {
        this.val = String(s);
    }
    this(T)(T val) {
        this.val = val;
    }

    override const nothrow @safe size_t toHash() {
        return val.toHash();
    }
    private static auto getName(T)() {
        static if ( __traits(compiles, "T.type"))
            return T.type;
        else return typeid(T);
    }
    T* getPtr(T)(Pos pos) {
        auto a = val.peek!T;
        if (a is null)
            throw new RuntimeException(pos, format!"Expected type %s, got %s"(getName!T, type()));
        return a;
    }

    T get(T)(Pos pos) {
        import stdd.traits;
        static if (is(T==Obj)) return this;
        else static if (is(T==tsint)) return get!Int(pos).val;
        else static if (is(T==bool)) return get!Bool(pos).val;
        else static if (is(T==tsfloat)) return get!Float(pos).val;
        else static if (is(T==tsstring)) return get!String(pos).val;
        else static if (isPointer!T) {
            return getPtr!(PointerTarget!T)(pos);
        }
        else {
            auto a = val.peek!T;
            if (a is null)
                throw new RuntimeException(pos, format!"Expected type %s, got %s"(getName!T, type()));
            return *a;
        }
    }
    private T trustedMemberCall(T, A...)(tsstring s, A args) {
        return member(Pos(-1), s).call(Pos(-1), null, args).get!T(Pos(-1));
    }
    override string toString() {
        throw new Exception("please use toStr", __FILE__, __LINE__);
    }
    tsstring toStr() {
        return trustedMemberCall!tsstring("toString", this);
    }
    bool toBool() {
        return trustedMemberCall!bool("toBool", this);
    }
    bool equals(Obj o) {
        return trustedMemberCall!bool("opEquals", this);
    }
    tsint cmp(Pos p, Env e, Obj other) {
        auto f = typeTable.tryMember(type(), "opCmp");
        if (f !is null) {
            auto r = f.call(p, e, this, other);
            if (!r.isNil())
                return r.get!tsint(p);
        }
        f = typeTable.tryMember(other.type(), "opCmpR");
        if (f !is null) {
            auto r = f.call(p, e, other, this);
            if (!r.isNil())
                return -r.get!tsint(p);
        }
        throw new TypeException(p, format!"Binary 'opCmp', not overloaded for type %s"(type()));
    }
    Obj binary(Pos pos, Env env, tsstring op, Obj other) {
        auto f = typeTable.tryMember(type(), op);
        if (f !is null) {
            auto r = f.call(pos, env, this, other);
            if (!r.isNil())
                return r;
        }
        f = typeTable.tryMember(other.type(), op~"R");
        if (f !is null) {
            auto r = f.call(pos, env, other, this);
            if (!r.isNil())
                return r;
        }
        throw new TypeException(pos, format!"Binary '%s', not overloaded for type %s"(op, type()));
    }
    Obj binary(tsstring op)(Pos pos, Env env, Obj other) {
        enum name = symbolicToTT(op).binaryFunctionName;
        static assert(name.length > 0);
        return binary(pos, env, name, other);
    }

    /*
    Obj call(T...)(Pos pos, Env env, T a) {
        return call(pos, env, [a]);
        }*/

    Obj call(Pos p, Env e, Obj[] args...) {
        //dfmt off
        return val.tryVisit!(
            (Function f) => f(p, e, args),
            (Closure f) => f(p, e, args),
            (BIFunction f) => f(p, e, args),
            (BIOverloads f) => f(p, e, args),
            (Type_ f) => f.callCtor(p, e, args),
            //() => member(p, "opCall").call(p, e, args)
            () => throwRtrn!(Obj, RuntimeException)(p, format!"Expected function, found %s"(type))
        )();
        //dfmt on
    }
    Obj member(Pos p, tsstring m) {
        return typeTable.getMember(p, type, m);
    }
    @property tsstring type() {
        string gen() {
            auto r = "val.visit!(";
            static foreach (t; types) {
                r ~= format!"(%s v) => %s.type(),"(t,t);
            }
            return r ~ ")";
        }
        return mixin(gen());
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

}

static foreach (t; types)
    mixin(format!`Obj obj%s(A...)(A args) {
                      return new Obj(%s(args));
                  }`(t[$-1] =='_'? t[0..$-1]: t, t));
unittest {
    import stdd.stdio;

    Obj o = objString("s");
    writeln(o.toString);
    writeln(Nil.toString);
    assert(Nil.toString() == "nil");
}
