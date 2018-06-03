module ts.objects.type;

import ts.objects;

struct Type_ {
    tsstring name;
    Obj function() creator;
    this(tsstring name, Obj function() creator) {
        this.name = name;
        this.creator = creator;
    }
    Obj callCtor(Pos p, Env e, Obj[] a) {
        auto ctor = typeTable.getCtor(p, name);
        Obj obj = creator();
        import stdd.array;
        Obj[] args = uninitializedArray!(Obj[])(a.length + 1);
        args[0] = obj;
        args[1..$] = a[];
        /*
        typeTable.tryCtor!T.call(p, e, args);
        return v;*/
        ctor.call(p, e, args);
        return obj;
    }
static:
    tsstring type() { return "__type__"; }
    Obj opCall(Pos p, Env e, Type_ t, Obj[] args) {
        return t.callCtor(p,e,args);
    }
    Obj opFwd(Pos p, Env e, Type_ t, tsstring m) {
        return typeTable.get(t.name).members[m];
    }
    Obj opFwdSet(Pos p, Env e, Type_ t, tsstring m, Obj val) {
        return typeTable.get(t.name).members[m] = val;
    }
}
