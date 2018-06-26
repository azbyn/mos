module mos.runtime.env;

import mos.objects.obj;
import mos.objects.property;
import mos.objects.type_meta;
import mos.ir.block_manager;
import stdd.array;
import stdd.format : format;
import mos.misc : mosformat;

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

    this(BlockManager man) {
        this.man = man;
        // objs = minimallyInitializedArray!(Obj[])(st.names.length);
    }
    this(Env parent, BlockManager man, Obj*[uint] captures) {
        this(man);
        if (parent !is null)
            this.captures = parent.captures;
        if (captures !is null) {
            foreach (k, o; captures) {
                this.captures[k] = o;
            }
        }
    }
    Obj get(Pos p, mosstring val) { return get(p, man.getIndex(val)); }
    Obj get(Pos p, uint val){
        if (auto ptr = objs.get(val, null))
            return ptr.checkGetter(p, this);
        if (auto o = captures.get(val, null))
            return o.checkGetter(p, this);
        throw new RuntimeException(p, format!"'%s' not defined"(man.getStr(val)));
    }
    Obj* getPtr(uint val) {
        if (auto ptr = val in objs)
            return ptr;
        if (auto o = captures.get(val, null))
            return o;
        throw new Exception(format!"'%s' not defined"(man.getStr(val)));
    }

    Obj set(Pos p, mosstring val, Obj o) { return set(p, man.getIndex(val), o); }
    Obj set(Pos p, uint val, Obj o) {
        //moslog!"<<<set %s"(man.getStr(val));
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

    TypeMeta getTypeMeta(Pos p, mosstring name, string file =__FILE__, size_t line = __LINE__) {
        size_t li;
        if (man.lib.get(name, li)) {
            import mos.runtime.interpreter : checkGetter;
            return man.lib.get(li).checkGetter(p, this).get!TypeMeta(p);
        }
        if (auto ptr = objs.get(man.getIndex(name), null))
            return ptr.get!TypeMeta(p);
        throw new RuntimeException(p, format!"'%s' not defined"(name), file, line);
    }
}
