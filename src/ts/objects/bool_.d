module ts.objects.bool_;

import ts.objects;
import ts.runtime.env;
import ts.ast.token;
import stdd.conv : to;
import stdd.format;
import stdd.variant;

mixin TSModule!(ts.objects.bool_);

@tsexport struct Bool {
    bool val;

static:
    mixin TSType!"bool";
    @tsexport {
        void ctor(Bool v) { v.val = false; }
        void ctor(Pos p, Env e, Bool v, Obj val) {
            val.visitO!(
                (Bool b) { v.val = b.val; },
                (String s) {
                    if (s.val == "true") v.val = true;
                    else if (s.val == "false") v.val = false;
                    else throw new RuntimeException(p, format!"Can't parse '%s' to a bool"(v.val));
                },
                () { v.val = val.toBool(p, e); })();
        }

        tsstring toString(bool b) { return b ? "true" : "false"; }
        bool opNot(bool b) { return !b; }
        bool opEquals(bool v, Obj oth) {
            return oth.visitO!(
                (Bool b) => v == b.val,
                () => false);
        }

        bool toBool(bool b) { return b; }
    }
}
