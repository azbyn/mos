module mos.objects.bool_;

import mos.objects;
import mos.runtime.env;
import mos.ast.token;
import stdd.conv : to;
import stdd.format;
import stdd.variant;

mixin MOSModule!(mos.objects.bool_);

@mosexport struct Bool {
    bool val;

static:
    mixin MOSType!"bool";
    @mosexport {
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

        mosstring toString(bool b) { return b ? "true" : "false"; }
        bool opNot(bool b) { return !b; }
        bool opEquals(bool v, Obj oth) {
            return oth.visitO!(
                (Bool b) => v == b.val,
                () => false);
        }

        bool toBool(bool b) { return b; }
    }
}
