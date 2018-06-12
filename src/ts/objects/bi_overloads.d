module ts.objects.bi_overloads;

import ts.objects.obj;
import ts.ast.token;
import ts.runtime.env;
import stdd.format;

struct BIOverloads {
    Obj function(Pos, Env, Obj[])[int] val;
    this(Obj function(Pos, Env, Obj[])[int] val) {
        this.val = val;
    }

    Obj opCall(Pos pos, Env env, Obj[] a, string file = __FILE__, size_t line = __LINE__) {
        if (auto v = val.get(cast(int) a.length, null)) {
            return v(pos, env, a);
        }
        if (auto v = val.get(-1, null)) {
            return v(pos, env, a);
        }
        string s = "";
        foreach (a, _; val) s ~= format!"%d, "(a);
        throw new RuntimeException(pos, format!"no overload takes %s args (only %s)"(a.length, s), file, line);
    }
static:
    TypeMeta typeMeta;
    tsstring type() { return "function_ol"; }
    tsstring toString(BIOverloads f) { return "function_ol"; }
}

