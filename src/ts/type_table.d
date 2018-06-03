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
}

class TypeTable {
    Type[tsstring] data;
    /*void print() {
        import com.log;
        ("<TypeTable>");
        foreach(n, t; data) {
            writefln("  <%s>", n);
            foreach (m, v; t.members) {
                writefln("    %s: %s", m, v);
            }
        }
        writeln("</TypeTable>");
        }*/
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
    Obj getCtor(T)(Pos p) {
        if(auto ctor = get!T.ctor) return ctor;
        throw new TypeException(p, format!"Type '%s' doesn't have a ctor"(getName!T));
    }
    Obj getCtor(Pos p, tsstring t) {
        if(auto ctor = get(t).ctor) return ctor;
        throw new TypeException(p, format!"Type '%s' doesn't have a ctor"(t));
    }

    Obj tryCtor(T)() { return get!T.ctor; }
    Obj getMember(Pos pos, tsstring type, tsstring s) {
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
