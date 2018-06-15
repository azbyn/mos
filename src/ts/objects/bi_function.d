module ts.objects.bi_function;

import ts.objects.obj;
import ts.ast.token;
import ts.runtime.env;

mixin TSModule!(ts.objects.bi_function);

@tsexport struct BIFunction {
    Obj function(Pos, Env, Obj[]) val;
    this(Obj function(Pos, Env, Obj[]) @system val) {
        this.val = val;
    }

    Obj opCall(Pos pos, Env env, Obj[] a) { return val(pos, env, a); }
static:
    __gshared TypeMeta typeMeta;
    enum tsstring type = "function_bi";
}

@tsexport struct BIMethodMaker {
    Obj delegate(Obj) val;
    this(Obj delegate(Obj) val) {
        this.val = val;
    }
    Obj callThis(Obj this_) { return val(this_); }

static:
    __gshared TypeMeta typeMeta;
    enum tsstring type = "method_maker";
}
@tsexport struct BIClosure {
    Obj delegate(Pos, Env, Obj[]) val;
    this(Obj delegate(Pos, Env, Obj[]) val) {
        this.val = val;
    }

    Obj opCall(Pos pos, Env env, Obj[] a) { return val(pos, env, a); }
static:
    __gshared TypeMeta typeMeta;
    enum tsstring type = "closure_bi";
}
@tsexport struct BIMethodOverloads {
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
    __gshared TypeMeta typeMeta;
    enum tsstring type = "function_mol";
}
