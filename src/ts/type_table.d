module ts.type_table;

import ts.objects.obj;
import ts.ast.token;
import ts.misc;
import stdd.format;
import stdd.algorithm;
import stdd.array;

class TypeException : TSException {
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        super(pos, msg, file, line);
    }
}

struct Type {
    Obj ctor;
    Obj[tsstring] members;
    Obj delegate(Pos p, Env e) creator;
    Obj callCtor(Pos p, Env e, Obj[] a) {
        assert(ctor);
        assert(creator);
        import stdd.array;
        Obj obj = creator(p, e);
        Obj[] args = uninitializedArray!(Obj[])(a.length + 1);
        args[0] = obj;
        args[1..$] = a[];
        ctor.call(p, e, args);
        return obj;
    }
}

class TypeTable {
    Type[tsstring] data;

    this(TypeTable tt) {
        this.data = tt.data.dup();
    }
    this() {
        
    }

    tsstring getName(T)() {
        return T.type();
    }
    Type* get(T)() {
        return &data[getName!T];
    }
    Type* get(tsstring t) {
        return &data[t];
    }
    void add(T)(Type t) {
        data[getName!T] = t;
    }
    void add(tsstring name, Type t) {
        data[name] = t;
    }
    Obj construct(tsstring name, Pos p, Env e, Obj[] args...) {
        return data[name].callCtor(p, e, args);
    }

    Obj getCtor(T)(Pos p) {
        if(auto ctor = get!T.ctor) return ctor;
        throw new TypeException(p, format!"Type '%s' doesn't have a ctor"(getName!T));
    }
    Obj getCtor(Pos p, tsstring t) {
        if(auto ctor = get(t).ctor) return ctor;
        throw new TypeException(p, format!"Type '%s' doesn't have a ctor"(t));
    }

    Obj tryCtor(T)() { return get!T.ctor; }
    Obj getMember(Pos p, Env e, Obj a, tsstring val) {
        import ts.objects.property;
        return getMember2(p, a.type(), tsformat!"%s"(val), "opFwd",
                          (Obj f) =>f.val.tryVisit!(
                              (Property pr) => pr.callGetMember(p, e, a),
                              () => f),
                          (Obj f) => f.call(p, e, a, objString(val)));
    }
    Obj getMember_(Pos pos, tsstring type, tsstring s) {
        if (type !in data)
            throw new TypeException(pos, format!"type '%s' not defined"(type));
        auto m = data[type].members.get(s, null);
        if (m is null)
            throw new TypeException(pos, format!"Type '%s' doesn't have member '%s'"(type, s));
            return m;
    }
    auto getMember2(F1, F2)(Pos pos, tsstring type, tsstring s1, tsstring s2, F1 f1, F2 f2) {
        if (auto m = tryMember(type, s1)) {
            return f1(m);
        }
        if (auto m = tryMember(type, s2)) {
            return f2(m);
        }
        throw new TypeException(pos, format!"Type '%s' doesn't have neither '%s', nor '%s'"(type, s1, s2));
    }

    Obj tryMember(tsstring type, tsstring s) {
        if (type !in data)
            return null;
        auto m = data[type].members.get(s, null);
        if (m is null)
            return null;
        return m;
    }
}
