module ts.objects.bi_function;

import ts.objects.obj;
import ts.ast.token;
import ts.runtime.env;

struct BIFunction {
    Obj function(Pos, Env, Obj[]) val;
    this(Obj function(Pos, Env, Obj[]) @system val) {
        this.val = val;
    }

    Obj opCall(Pos pos, Env env, Obj[] a) { return val(pos, env, a); }
static:
    TypeMeta typeMeta;
    tsstring type() { return "function_bi"; }

    tsstring toString(BIFunction f) { return "function_bi"; }
}

