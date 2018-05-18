module ts.objects.string_;

import ts.objects;
import ts.runtime.env;
import ts.ast.token;
import stdd.conv;
import stdd.format;

struct String {
    tsstring val;
static:
    void ctor(String v) { v.val = ""; }
    void ctor(Pos p, Env e, String v, Obj obj) {
        obj.val.tryVisit!(
            (String s) => v.val = s.val,
            () => v.val = obj.toStr,
        )();
    }

    tsstring toString(String v) { return v.val; }
    tsstring type() { return "string"; }
    tsstring opCat (Pos p, Env e, String v, Obj obj) { return v.val ~ obj.toStr(); }
    tsstring opCatR(Pos p, Env e, String v, Obj obj) { return obj.toStr() ~ v.val; }

    bool toBool(String v) { return v.val != ""; }
}


