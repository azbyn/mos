module ts.runtime.env;

import ts.objects.obj;
import ts.objects.property;
import ts.objects.type_meta;
import ts.ir.symbol_table;
import ts.ir.block_manager;
import stdd.array;
import stdd.format : format;
import ts.misc : tsformat;

private Obj checkGetter(Obj x, Pos pos, Env env) {
    return x.visitO!(
        (Property p) => p.callGet(pos, env),
        () => x);
}
private Obj checkGetter(Obj* x, Pos pos, Env env) {
    return x.visitO!(
        (Property p) => p.callGet(pos, env),
        () => *x);
}

private Obj checkSetter(Obj* x, Pos pos, Env env, Obj val) {
    if (*x is null)
        return *x = val;
    return x.visitO!(
        (Property p) => p.callSet(pos, env, val),
        () => *x = val);
}

class Env {
    Obj[uint] objs;
    BlockManager man;
    Obj*[uint] captures;

    this(SymbolTable st) {
        this.man = st.man;
        foreach (n; st.symbols) {
            objs[n] = nil;
        }
        // objs = minimallyInitializedArray!(Obj[])(st.names.length);
    }
    this(Env parent, SymbolTable st, Obj*[uint] captures) {
        this(st);
        if (parent !is null)
            this.captures = parent.captures;
        if (captures !is null) {
            foreach (k, o; captures) {
                this.captures[k] = o;
            }
        }
    }
    Obj get(Pos p, tsstring val) { return get(p, man.getIndex(val)); }
    Obj get(Pos p, uint val){
        if (auto ptr = objs.get(val, null))
            return ptr.checkGetter(p, this);
        if (auto o = captures.get(val, null))
            return o.checkGetter(p, this);
        assert(0, format!"get %s"(val));
    }
    Obj* getPtr(uint val) {
        if (auto ptr = val in objs)
            return ptr;
        if (auto o = captures.get(val, null))
            return o;
        assert(0);

    }

    Obj set(Pos p, tsstring val, Obj o) { return set(p, man.getIndex(val), o); }
    Obj set(Pos p, uint val, Obj o) {
        //tslog!"<<<set %s"(man.getStr(val));
        if (auto ptr = captures.get(val, null))
            return checkSetter(ptr, p, this, o);

        if (auto ptr = val in objs)
            ptr.visitO!(
                (Property prop) => prop.callSet(p, this, o),
                () => *ptr = o);
        return objs[val] = o;
    }

    Obj getterDef(Pos p, uint val, Obj o) {
        if (val in captures) {
            throw new RuntimeException(p, "can't define getter for captured variable");
        }
        return assignGetter(objs, val, o);
    }

    Obj setterDef(Pos p, uint val, Obj o) {
        if (val in captures) {
            throw new RuntimeException(p, "can't define setter for captured variable");
        }
        return assignSetter(objs, val, o);
    }
    /*
    Obj propDef(Pos p, uint val, Obj get, Obj set) {
        if (val in captures) {
            throw new RuntimeException(p, "can't define alias for captured variable");
        }
        return objs[val] = obj!Property(get, set);
    }*/

    import com.log;

    TypeMeta getTypeMeta(Pos p, tsstring name, string file =__FILE__, size_t line = __LINE__) {
        size_t li;
        if (man.lib.get(name, li)) {
            import ts.runtime.interpreter : checkGetter;
            return man.lib.get(li).checkGetter(p, this).get!TypeMeta(p);
        }
        if (auto ptr = objs.get(man.getIndex(name), null))
            return ptr.get!TypeMeta(p);
        throw new RuntimeException(p, format!"'%s' not defined"(name), file, line);
    }
    /+
    Obj getMember(Pos p, Obj a, tsstring val, string file =__FILE__, size_t line = __LINE__) {
        import ts.objects.property;
        //dfmt off
        return getMember2(p, a, val, "opFwd",
                          (Obj f) =>f.visitO!(
                              (Property pr) => pr.callGetMember(p, this, a),
                              (BIMethodMaker m) => m.callThis(a),
                              () => f),
                          (Obj f) => f.visitO!(
                              (BIMethodMaker m) => m.callThis(a),
                              () => f).call(p, this, a, obj!String(val)));
        //dfmt on
    }

    Obj getMember_(Pos p, Obj o, tsstring s) {
        auto m = o.typeMeta.members.get(s, null);
        if (m is null)
            throw new TypeException(p, format!"Type '%s' doesn't have member '%s'"(o.typestr, s));
        return m;
    }

    auto getMember2(F1, F2)(Pos p, Obj o, tsstring s1, tsstring s2, F1 f1, F2 f2,
                            string file =__FILE__, size_t line = __LINE__) {
        if (auto m = tryMember(o, s1)) {
            return f1(m);
        }
        if (auto m = tryMember(o, s2)) {
            return f2(m);
        }
        throw new TypeException(p,
                                format!"Type '%s' doesn't have neither '%s', nor '%s'"(o.typestr, s1, s2), file, line);
    }

    Obj tryMember(Obj o, tsstring s) {
        return o.typeMeta.members.get(s, null);
    }+/
}
