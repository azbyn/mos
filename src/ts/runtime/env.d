module ts.runtime.env;

import ts.objects.obj;
import ts.objects.property;
import ts.ir.symbol_table;
import ts.ir.compiler : OffsetVal;
import stdd.array;
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
    Obj*[OffsetVal] captures;

    this(SymbolTable st) {
        offset = st.offset;
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
    Obj get(T)(Pos p, Env e, T val) { return get(p,e,OffsetVal(val.offset, val.val)); }
    Obj get(Pos p, Env e, OffsetVal val){
        if (val.offset == offset)
            return objs[val.val].checkGetter(p, e);
        if (auto o = captures.get(val, null))
            return o.checkGetter(p, e);
        assert(0);
    }
    Obj* getPtr(OffsetVal val) {
        if (val.offset == offset)
            return &objs[val.val];
        if (auto o = captures.get(val, null))
            return o;
        assert(0);

    }
    Obj set(T)(Pos p, Env e, T val, Obj o) { return set(p,e,OffsetVal(val.offset, val.val), o); }
    Obj set(Pos p, Env e, OffsetVal val, Obj o) {
        if (val.offset == offset) {
            return checkSetter(&objs[val.val], p, e, o);
        }
        auto ptr = val in captures;
        if (ptr !is null) {
            return checkSetter(*ptr, p, e, o);
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

}
