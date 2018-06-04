module ts.objects.function_;

import ts.objects.obj;
import ts.ir.block;
import ts.ast.token;
import ts.runtime.env;
import ts.runtime.interpreter;
import ts.misc;

struct Function {
    Block val;
    this(Block val) {
        this.val = val;
    }

    Obj opCall(Pos pos, Env env, Obj[] args,string file =__FILE__, size_t line = __LINE__) {
        return val.eval(pos, env, args, null, file,line);
    }
static:
    TypeMeta typeMeta;
    tsstring type() { return "function"; }

    tsstring toString(Pos p, Env e, Function v) {
        return tsformat!"\n<function>%s\n</function>"(v.val.toStr(p, e));
    }
}
