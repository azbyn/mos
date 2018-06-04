module ts.objects.type_meta;

import ts.objects;

struct TypeMeta {
    tsstring name;

    this(tsstring name) {
        this.name = name;
    }

    Obj callCtor(Pos p, Env e, Obj[] a) {
        return typeTable.construct(name, p, e, a);
    }

static:
    tsstring type() {
        return "__type_meta__";
    }
    tsstring toString(TypeMeta tm) {
        return "__type_meta__@"~ tm.name;
    }
    /*Obj opCall(Pos p, Env e, Type_ t, Obj[] args) {
        return t.callCtor(p,e,args);
        }*/
    Obj opFwd(Pos p, Env e, TypeMeta t, tsstring m) {
        return typeTable.get(t.name).members[m];
    }

    Obj opFwdSet(Pos p, Env e, TypeMeta t, tsstring m, Obj val) {
        return typeTable.get(t.name).members[m] = val;
    }
}
