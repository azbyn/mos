module mos.objects.closure;

import mos.objects.obj;
import mos.ir.block;
import mos.ast.token;
import mos.runtime.env;
import mos.runtime.interpreter;
import mos.misc;

mixin MOSModule!(mos.objects.closure);

@mosexport struct StaticClosure {
    Block val;
    Obj*[uint] captures;
    this(Block val, Obj*[uint] captures) {
        this.val = val;
        this.captures = captures;
    }

    Obj opCall(Pos pos, Env env, Obj[] args) {
        return val.eval(null, pos, env, args, captures);
    }
static:
    mixin MOSType!"closure";
    @mosexport mosstring toString(Pos p, Env e, StaticClosure v) {
        mosstring res = "<closure>\n";
        foreach (k, o; v.captures)
            res ~= mosformat!"@%s:%s\n"(k, o.toStr(p, e));
        res ~= "Code:\n"~ v.val.toStr(p, e);
        return res ~ "\n</closure>";
    }
}
@mosexport struct MethodClosure {
    Block val;
    Obj*[uint] captures;
    Obj this_;
    this(Obj this_, Block val, Obj*[uint] captures) {
        this.val = val;
        this.captures = captures;
        this.this_ = this_;
    }

    Obj opCall(Pos pos, Env env, Obj[] args) {
        return val.eval(this_, pos, env, args, captures);
    }
static:
    mixin MOSType!"mthd_closure";
    @mosexport mosstring toString(Pos p, Env e, MethodClosure v) {
        mosstring res = "<mthd_closure>\ncaps_vals:\n";
        foreach (k, o; v.captures)
            res ~= mosformat!"@%s:%s\n"(k, o.toStr(p, e));
        res ~= v.val.toStr(p, e);
        return res ~ "\n</mthd_closure>";
    }
}
@mosexport struct MethodClosureMaker {
    Block val;
    Obj*[uint] captures;
    this(Block val, Obj*[uint] captures) {
        this.val = val;
        this.captures = captures;
    }
    Obj callThis(Obj this_) {
        return obj!MethodClosure(this_, val, captures);
    }

static:
    mixin MOSType!"mthd_closure_mkr";
    @mosexport mosstring toString(Pos p, Env e, MethodClosureMaker v) {
        mosstring res = "<mthd_closure_mkr>\ncaps_vals:\n";
        foreach (k, o; v.captures)
            res ~= mosformat!"@%s:%s\n"(k, o.toStr(p, e));
        res ~= v.val.toStr(p, e);
        return res ~ "\n</mthd_closure_mkr>";
    }
}
