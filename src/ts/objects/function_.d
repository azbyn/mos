module ts.objects.function_;

import ts.objects.obj;
import ts.ir.block;
import ts.ast.token;
import ts.runtime.env;
import ts.runtime.interpreter;
import ts.misc;

mixin TSModule!(ts.objects.function_);

@tsexport struct StaticFunction {
    Block val;
    this(Block val) {
        this.val = val;
    }

    Obj opCall(Pos pos, Env env, Obj[] args, string file =__FILE__, size_t line = __LINE__) {
        return val.eval(null, pos, env, args, null, file, line);
    }
static:
    mixin TSType!"function";

    @tsexport tsstring toString(Pos p, Env e, StaticFunction v) {
        return tsformat!"\n<function>%s\n</function>"(v.val.toStr(p, e));
    }
}
@tsexport struct MethodFunction {
    Block val;
    Obj this_;
    this(Obj this_, Block val) {
        this.val = val;
        this.this_ = this_;
    }

    Obj opCall(Pos pos, Env env, Obj[] args, string file =__FILE__, size_t line = __LINE__) {
        return val.eval(this_, pos, env, args, null, file, line);
    }
static:
    mixin TSType!"mthd_function";

    @tsexport tsstring toString(Pos p, Env e, MethodFunction v) {
        return tsformat!"\n<function>%s\n</function>"(v.val.toStr(p, e));
    }
}
@tsexport struct MethodFunctionMaker {
    Block val;
    this(Block val) {
        this.val = val;
    }
    Obj callThis(Obj this_) {
        return obj!MethodFunction(this_, val);
    }

static:
    mixin TSType!"mthd_function_mkr";

    @tsexport tsstring toString(Pos p, Env e, MethodFunctionMaker v) {
        return tsformat!"\n<mthd_function_mkr>%s\n</mthd_function_mkr>"(v.val.toStr(p, e));
    }
}

