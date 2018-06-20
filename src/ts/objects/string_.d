module ts.objects.string_;

import ts.objects;
import ts.runtime.env;
import ts.ast.token;
import stdd.conv;
import stdd.format;

mixin TSModule!(ts.objects.string_);

@tsexport struct String {
    tsstring val;
static:
    mixin TSType!"string";
    @tsexport {
        void ctor(String v) { v.val = ""; }
        void ctor(Pos p, Env e, String v, Obj obj) {
            obj.visitO!(
                (String s) => v.val = s.val,
                () => v.val = obj.toStr(p, e),
            )();
        }
        tsstring toString(String v) { return v.val; }

        tsstring opCat (Pos p, Env e, String v, Obj obj) { return v.val ~ obj.toStr(p,e); }
        tsstring opCatR(Pos p, Env e, String v, Obj obj) { return obj.toStr(p, e) ~ v.val; }

        bool opEquals(tsstring v, Obj oth) {
            return oth.visitO!(
                (String s) => v == s.val,
                () => false);
        }

        bool toBool(String v) { return v.val != ""; }
    }
}


