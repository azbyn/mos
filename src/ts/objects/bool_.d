module ts.objects.bool_;

import ts.objects;
import ts.runtime.env;
import ts.ast.token;
import stdd.conv : to;
import stdd.format;
import stdd.variant;

struct Bool {
    bool val;

static:
    void ctor(Bool v) { v.val = false; }
    void ctor(Pos p, Env e, Bool v, Obj val) {
        val.val.tryVisit!(
            (Bool b) { v.val = b.val; },
            (String s) {
                if (s.val == "true") v.val = true;
                else if (s.val == "false") v.val = false;
                else throw new RuntimeException(p, format!"Can't parse '%s' to a bool"(v.val));
            },
            () { v.val = val.toBool(); })();
    }

    tsstring toString(bool b) { return b ? "true" : "false"; }
    tsstring type() { return "bool"; }
    bool opNot(bool b) { return !b; }
    bool opEquals(bool v, Obj oth) {
        return oth.val.tryVisit!(
            (Bool b) => v == b.val,
            () => false);
    }

    bool toBool(bool b) { return b; }
}
