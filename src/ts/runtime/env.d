module ts.runtime.env;

import ts.objects.obj;
import ts.objects.property;
import ts.objects.type_meta;
import ts.ir.symbol_table;
import ts.ir.compiler : OffsetVal;
import stdd.array;
import stdd.format : format;
import ts.misc : tsformat;

private Obj checkGetter(Obj x, Pos pos, Env env) {
    return x.val.tryVisit!(
        (Property p) => p.callGet(pos, env),
        () => x);
}
private Obj checkGetter(Obj* x, Pos pos, Env env) {
    return x.val.tryVisit!(
        (Property p) => p.callGet(pos, env),
        () => *x);
}

private Obj checkSetter(Obj* x, Pos pos, Env env, Obj val) {
    if (*x is null)
        return *x = val;
    return x.val.tryVisit!(
        (Property p) => p.callSet(pos, env, val),
        () => *x = val);
}

class Env {
    ushort offset;
    Obj[] objs;
    SymbolTable st;
    Obj*[OffsetVal] captures;

    this(SymbolTable st) {
        offset = st.offset;
        this.st = st;
        objs = minimallyInitializedArray!(Obj[])(st.names.length);
    }
    this(Env parent, SymbolTable st, Obj*[OffsetVal] captures) {
        this(st);
        if (parent !is null)
            this.captures = parent.captures;
        if (captures !is null) {
            foreach (k, o; captures) {
                this.captures[k] = o;
            }
        }
    }
    Obj get(T)(Pos p, T val) { return get(p, OffsetVal(val.offset, val.val)); }
    Obj get(Pos p, OffsetVal val){
        if (val.offset == offset)
            return objs[val.val].checkGetter(p, this);
        if (auto o = captures.get(val, null))
            return o.checkGetter(p, this);
        import stdd.format;
        assert(0, format!"get %s"(val));
    }
    Obj* getPtr(OffsetVal val) {
        if (val.offset == offset)
            return &objs[val.val];
        if (auto o = captures.get(val, null))
            return o;
        assert(0);

    }
    Obj set(T)(Pos p, T val, Obj o) { return set(p, OffsetVal(val.offset, val.val), o); }
    Obj set(Pos p, OffsetVal val, Obj o) {
        if (val.offset == offset) {
            return checkSetter(&objs[val.val], p, this, o);
        }
        auto ptr = val in captures;
        if (ptr !is null) {
            return checkSetter(*ptr, p, this, o);
        }
        assert(0);
    }

    Obj getterDef(T)(Pos p, T val, Obj o) { return getterDef(p, OffsetVal(val.offset, val.val), o); }
    Obj getterDef(Pos p, OffsetVal val, Obj o) {
        if (val.offset == offset) {
            return assignGetter(objs, val.val, o);
        }
        if (val in captures) {
            throw new RuntimeException(p, "can't define getter for captured variable");
        }
        assert(0);
    }

    Obj setterDef(T)(Pos p, T val, Obj o) { return setterDef(p, OffsetVal(val.offset, val.val), o); }
    Obj setterDef(Pos p, OffsetVal val, Obj o) {
        if (val.offset == offset) {
            return assignSetter(objs, val.val, o);
        }
        if (val in captures) {
            throw new RuntimeException(p, "can't define setter for captured variable");
        }
        assert(0);
    }
    /*
    Obj construct(Pos p, tsstring name, Obj[] args...){
        return getTypeMeta(p, name).construct(p, this, args);
        }*/
    import com.log;
    /*
    Obj addTypeMeta(Pos p, OffsetVal val, TypeMeta tm) {
        tslog!"<<added@%d [%s] : %s"(offset, val, tm.name);
        return set(p, val, new Obj(tm));
        }*/
    TypeMeta getTypeMeta(Pos p, tsstring name,  string file =__FILE__, size_t line = __LINE__) {
        OffsetVal ov;
        tslog!"src@%d %s"(offset, name);
        tslog!"st: %s"(st.names);
        if (st.getName(name, ov)) {
            return get(p, ov).get!TypeMeta(p);
        }
        size_t li;
        if (st.man.lib.get(name, li)) {
            import ts.runtime.interpreter : checkGetter;
            return st.man.lib.get(li).checkGetter(p, this).get!TypeMeta(p);
        }
        throw new RuntimeException(p, format!"'%s' not defined"(name), file, line);
    }
    TypeMeta getTypeMeta(Pos p, Obj o, string file =__FILE__, size_t line = __LINE__) {
        import ts.objects;
        string gen() {
            auto r = "o.val.visit!(";
            static foreach (t; ts.objects.obj.types) {
                static if (t == "UserDefined")
                    r ~= "(UserDefined v) => getTypeMeta(p, v.name, file,line),";
                else
                    r ~= format!"(%s v) => %s.typeMeta,"(t, t);
            }
            return r ~ ")";
        }
        /*
        return o.val.tryVisit!(
            (UserDefined v) => getTypeMeta(p, v.name, file, line),
            () => mixin(gen())
            )();*/
        return mixin(gen());
    }
    Obj getMember(Pos p, Obj a, tsstring val, string file =__FILE__, size_t line = __LINE__) {
        import ts.objects.property;
        //dfmt off
        return getMember2(p, a, val, "opFwd",
                (Obj f) => f.val.tryVisit!(
                    (Property pr) => pr.callGetMember(p, this, a),
                    () => f),
                (Obj f) => f.call(p, this, a, objString(val)), file ,line);
        //dfmt on
    }

    Obj getMember_(Pos p, Obj o, tsstring s, string file =__FILE__, size_t line = __LINE__) {
        auto m = getTypeMeta(p, o, file, line).members.get(s, null);
        if (m is null)
            throw new TypeException(p, format!"Type '%s' doesn't have member '%s'"(o.type, s));
        return m;
    }

    auto getMember2(F1, F2)(Pos p, Obj o, tsstring s1, tsstring s2, F1 f1, F2 f2,
                            string file =__FILE__, size_t line = __LINE__) {
        if (auto m = tryMember(p, o, s1, file, line)) {
            return f1(m);
        }
        if (auto m = tryMember(p, o, s2, file, line)) {
            return f2(m);
        }
        throw new TypeException(p,
            format!"Type '%s' doesn't have neither '%s', nor '%s'"(o.type, s1, s2));
    }

    Obj tryMember(Pos p, Obj o, tsstring s, string file =__FILE__, size_t line = __LINE__) {
        auto m = getTypeMeta(p, o, file, line).members.get(s, null);
        if (m is null)
            return null;
        return m;
    }
}
