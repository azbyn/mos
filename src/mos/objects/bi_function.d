module mos.objects.bi_function;

import mos.objects.obj;
import mos.ast.token;
import mos.runtime.env;

mixin MOSModule!(mos.objects.bi_function);

@mosexport struct BIFunction {
    Obj function(Pos, Env, Obj[]) val;
    this(Obj function(Pos, Env, Obj[]) @system val) {
        this.val = val;
    }

    Obj opCall(Pos pos, Env env, Obj[] a) { return val(pos, env, a); }
static:
    mixin MOSType!"function_bi";
}
@mosexport struct BIClosure {
    Obj delegate(Pos, Env, Obj[]) val;
    this(Obj delegate(Pos, Env, Obj[]) val) {
        this.val = val;
    }

    Obj opCall(Pos pos, Env env, Obj[] a) { return val(pos, env, a); }
static:
    mixin MOSType!"closure_bi";
}
@mosexport struct BIMethodOverloads {
    Obj this_;
    Obj function(Pos, Env, Obj[])[int] val;
    this(Obj this_, Obj function(Pos, Env, Obj[])[int] val) {
        this.this_ = this_;
        this.val = val;
    }

    Obj opCall(Pos pos, Env env, Obj[] a, string file = __FILE__, size_t line = __LINE__) {
        if (auto v = val.get(cast(int) a.length + 1, null)) {
            return v(pos, env, this_ ~ a);
        }
        if (auto v = val.get(-1, null)) {
            return v(pos, env, this_~ a);
        }
        string s = "";
        foreach (a, _; val) s ~= format!"%d, "(a-1);
        throw new RuntimeException(pos, format!"no overload takes %s args (only %s)"(a.length, s), file, line);
    }
static:
    mixin MOSType!"function_mol";
}
Obj methodMaker(T)(T t) {
    return obj!(MethodMaker_!T)(t);
}
@mosexport struct BIMethodMaker {
    Obj delegate(Obj) val;
    this(Obj delegate(Obj) val) {
        this.val = val;
    }

    static mk(Obj function(Obj) val) {
        import stdd.functional;
        return obj!BIMethodMaker(val.toDelegate);
    }

    Obj callThis(Obj this_) {
        return val(this_);
    }

static:
    mixin MOSType!"bi_method_maker";
}
