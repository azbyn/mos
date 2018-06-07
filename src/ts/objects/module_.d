module ts.objects.module_;

import ts.objects;
import ts.misc : tsformat;
import stdd.format : format;

struct Module {
    tsstring name;
    Obj[tsstring] members;


    this(tsstring name) {
        this.name = name;
    }

static:
    //super meta
    TypeMeta typeMeta;
    tsstring type() {
        return "__module__";
    }

    tsstring toString(Module t) {
        return tsformat!"__module@%s__"(t.name);
    }
    Obj opFwd(Pos p, Env e, Module* t, tsstring m) {
        Obj* x = m in t.members;
        if (x is null)
            throw new RuntimeException(p, format!"module '%s' doesn't contain '%s'"(t.name, m));
        return *x;
    }

    Obj opFwdSet(Pos p, Env e, Module* t, tsstring m, Obj val) {
        import ts.objects.property;
        tslog!"setting '%s' "(m);
        Obj* x = m in t.members;
        if (x is null)
            throw new RuntimeException(p, format!"module '%s' doesn't contain '%s'"(t.name, m));
        Property* prop = x.val.peek!Property;
        if (prop !is null)
            return prop.callSet(p, e, val);
        return *x = val;
        //return t.members[m] = val;
    }
}

Module tsenum(tsstring name, tsstring[] names...) {
    Module m = Module(name);
    foreach (i, n; names) {
        m.members[n] = objInt(i);
    }
    return m;
}
import com.log;
Module tsenum(tsstring name, tsstring[] names, tsint[] values) {
    assert(names.length == values.length);
    Module m = Module(name);
    foreach (i, n; names) {
        m.members[n] = objInt(values[i]);
    }
    return m;
}
Module tsenum(tsstring name, alias E)() if (is(E==enum)) {
    import stdd.format : format;
    tsstring[] names;
    tsint[] values;
    static foreach (x; __traits(allMembers, E)) {
        names ~= x;
        values ~= cast(tsint) mixin("E."~x);
    }
    return tsenum(name, names, values);
}
