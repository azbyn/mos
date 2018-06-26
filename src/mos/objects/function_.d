module mos.objects.function_;

import mos.objects.obj;
import mos.ir.block;
import mos.ast.token;
import mos.runtime.env;
import mos.runtime.interpreter;
import mos.misc;

mixin MOSModule!(mos.objects.function_);

@mosexport struct StaticFunction {
    Block val;
    this(Block val) {
        this.val = val;
    }

    Obj opCall(Pos pos, Env env, Obj[] args, string file =__FILE__, size_t line = __LINE__) {
        return val.eval(null, pos, env, args, null, file, line);
    }
static:
    mixin MOSType!"function";

    @mosexport mosstring toString(Pos p, Env e, StaticFunction v) {
        return mosformat!"\n<function>%s\n</function>"(v.val.toStr(p, e));
    }
}
@mosexport struct MethodFunction {
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
    mixin MOSType!"mthd_function";

    @mosexport mosstring toString(Pos p, Env e, MethodFunction v) {
        return mosformat!"\n<function>%s\n</function>"(v.val.toStr(p, e));
    }
}
@mosexport struct MethodFunctionMaker {
    Block val;
    this(Block val) {
        this.val = val;
    }
    Obj callThis(Obj this_) {
        return obj!MethodFunction(this_, val);
    }

static:
    mixin MOSType!"mthd_function_mkr";

    @mosexport mosstring toString(Pos p, Env e, MethodFunctionMaker v) {
        return mosformat!"\n<mthd_function_mkr>%s\n</mthd_function_mkr>"(v.val.toStr(p, e));
    }
}

