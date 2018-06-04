module ts.objects.string_;

import ts.objects;
import ts.runtime.env;
import ts.ast.token;
import stdd.conv;
import stdd.format;

struct String {
    tsstring val;
static:
    TypeMeta typeMeta;
    tsstring toString(String v) { return v.val; }

    void ctor(String v) { v.val = ""; }
    void ctor(Pos p, Env e, String v, Obj obj) {
        obj.val.tryVisit!(
            (String s) => v.val = s.val,
            () => v.val = obj.toStr(p, e),
        )();
    }

    tsstring type() { return "string"; }
    tsstring opCat (Pos p, Env e, String v, Obj obj) { return v.val ~ obj.toStr(p,e); }
    tsstring opCatR(Pos p, Env e, String v, Obj obj) { return obj.toStr(p, e) ~ v.val; }

    bool opEquals(tsstring v, Obj oth) {
        return oth.val.tryVisit!(
            (String s) => v == s.val,
            () => false);
    }

    bool toBool(String v) { return v.val != ""; }
}


