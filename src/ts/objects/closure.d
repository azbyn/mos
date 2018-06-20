module ts.objects.closure;

import ts.objects.obj;
import ts.ir.block;
import ts.ast.token;
import ts.runtime.env;
import ts.runtime.interpreter;
import ts.misc;

mixin TSModule!(ts.objects.closure);

@tsexport struct StaticClosure {
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
    mixin TSType!"closure";
    @tsexport tsstring toString(Pos p, Env e, StaticClosure v) {
        tsstring res = "<closure>\n";
        foreach (k, o; v.captures)
            res ~= tsformat!"@%s:%s\n"(k, o.toStr(p, e));
        res ~= "Code:\n"~ v.val.toStr(p, e);
        return res ~ "\n</closure>";
    }
}
@tsexport struct MethodClosure {
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
    mixin TSType!"mthd_closure";
    @tsexport tsstring toString(Pos p, Env e, MethodClosure v) {
        tsstring res = "<closure>\n";
        foreach (k, o; v.captures)
            res ~= tsformat!"@%s:%s\n"(k, o.toStr(p, e));
        res ~= "Code:\n"~ v.val.toStr(p, e);
        return res ~ "\n</closure>";
    }
}
