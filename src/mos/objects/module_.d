module mos.objects.module_;

import mos.objects;
import mos.misc : mosformat;
import stdd.format : format;

mixin MOSModule!(mos.objects.module_);

@mosexport struct Module {
    mosstring name;
    Obj[mosstring] members;


    this(mosstring name) {
        this.name = name;
    }

static:
    mixin MOSType!"__module__";
    @mosexport {
        mosstring toString(Module t) {
            return mosformat!"__module@%s__"(t.name);
        }
        Obj opFwd(Pos p, Env e, Module* t, mosstring m) {
            Obj* x = m in t.members;
            if (x is null)
                throw new RuntimeException(p, format!"module '%s' doesn't contain '%s'"(t.name, m));
            return *x;
        }

        Obj opFwdSet(Pos p, Env e, Module* t, mosstring m, Obj val) {
            import mos.objects.property;
            moslog!"setting '%s' "(m);
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
}

Module mosenum(mosstring name, mosstring[] names...) {
    Module m = Module(name);
    foreach (i, n; names) {
        m.members[n] = obj!Int(i);
    }
    return m;
}
import com.log;
Module mosenum(mosstring name, mosstring[] names, mosint[] values) {
    assert(names.length == values.length);
    Module m = Module(name);
    foreach (i, n; names) {
        m.members[n] = obj!Int(values[i]);
    }
    return m;
}
Module mosenum(mosstring name, alias E)() if (is(E==enum)) {
    import stdd.format : format;
    mosstring[] names;
    mosint[] values;
    static foreach (x; __traits(allMembers, E)) {
        names ~= x;
        values ~= cast(mosint) mixin("E."~x);
    }
    return mosenum(name, names, values);
}
