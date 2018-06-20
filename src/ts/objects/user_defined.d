module ts.objects.user_defined;
import ts.objects.obj;

mixin TSModule!(ts.objects.user_defined);

@tsexport struct UserDefined {
    //tsstring name;
    Obj[tsstring] vars;

    Obj get(Obj this_, Pos p, Env e, tsstring name) {
        auto ptr = name in vars;
        if (ptr is null)
            return this_.getStatic(p, e, name);
        return ptr.visitO!(
            (Property pr) => pr.callGet(p, e),
            (PropertyMember pm) => pm.callGet(p, e, this_),
            (MethodMaker m) => m.callThis(this_),
            () => *ptr);
    }
    Obj set(Obj this_, Pos p, Env e, tsstring name, Obj val) {
        auto ptr = name in vars;
        if (ptr !is null)
            return this_.setStatic(p, e, name, val);
        return ptr.visitO!(
            (Property pr) => pr.callSet(p, e, val),
            (PropertyMember pm) => pm.callSet(p, e, this_, val),
            //(BIMethodMaker m) => m.callThis(a).setMember(p, e, mem, val),
            () => *ptr = val);
    }

static:
    mixin TSType!"__user_defined__";
    @tsexport Obj opFwd(Pos p, Env e, Obj this_, tsstring name) {
        return this_.peek!UserDefined.get(this_, p, e, name);
    }
    @tsexport Obj opFwdSet(Pos p, Env e, Obj this_, tsstring name, Obj val) {
        return this_.peek!UserDefined.set(this_, p, e, name, val);
    }
}
