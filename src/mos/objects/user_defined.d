module mos.objects.user_defined;
import mos.objects.obj;

import com.log;

mixin MOSModule!(mos.objects.user_defined);

@mosexport struct UserDefined {
    //mosstring name;
    Obj[mosstring] vars;
    this(TypeMeta tm) {
        vars = tm.instance.dup();
        moslog!"<new ud>";
        foreach (n, _; vars) {
            moslog!"- %s"(n);
        }
        moslog("");
    }

    Obj get(Obj this_, Pos p, Env e, mosstring name) {
        moslog!"get %s"(name);
        //tslog!"from %s"(this_.typeMeta);
        moslog!"from %s"(this_.typeMeta.dbgString());
        auto ptr = name in vars;
        if (ptr is null)
            return this_.getStatic(p, e, name);
        moslog!"NOT STATIC: %s"(ptr.toStr(p,e));
        return ptr.visitO!(
            (Property pr) => pr.callGet(p, e),
            (PropertyMember pm) => pm.callGet(p, e, this_),
            (MethodClosureMaker m) {
                auto res = m.callThis(this_);
                moslog!"mm_res: %s %s"(res.typestr, res.toStr(p, e));
                return res;
            },
            (MethodFunctionMaker m) => m.callThis(this_),
            (BIMethodMaker bimm) => bimm.callThis(this_),
            () => *ptr);
    }
    Obj set(Obj this_, Pos p, Env e, mosstring name, Obj val) {
        auto ptr = name in vars;
        if (ptr is null)
            return this_.setStatic(p, e, name, val);
        return ptr.visitO!(
            (Property pr) => pr.callSet(p, e, val),
            (PropertyMember pm) => pm.callSet(p, e, this_, val),
            //(BIMethodMaker m) => m.callThis(a).setMember(p, e, mem, val),
            () => *ptr = val);
    }

static:
    mixin MOSType!"__user_defined__";
    @mosexport Obj opFwd(Pos p, Env e, Obj this_, mosstring name) {
        return this_.peek!UserDefined.get(this_, p, e, name);
    }
    @mosexport Obj opFwdSet(Pos p, Env e, Obj this_, mosstring name, Obj val) {
        return this_.peek!UserDefined.set(this_, p, e, name, val);
    }
}
