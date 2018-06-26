module mos.objects.string_;

import mos.objects;
import mos.runtime.env;
import mos.ast.token;
import stdd.conv;
import stdd.format;

mixin MOSModule!(mos.objects.string_);

@mosexport struct String {
    mosstring val;
static:
    mixin MOSType!"string";
    @mosexport {
        void ctor(String v) { v.val = ""; }
        void ctor(Pos p, Env e, String v, Obj obj) {
            obj.visitO!(
                (String s) => v.val = s.val,
                () => v.val = obj.toStr(p, e),
            )();
        }
        mosstring toString(String v) { return v.val; }

        mosstring opCat (Pos p, Env e, String v, Obj obj) { return v.val ~ obj.toStr(p,e); }
        mosstring opCatR(Pos p, Env e, String v, Obj obj) { return obj.toStr(p, e) ~ v.val; }

        bool opEquals(mosstring v, Obj oth) {
            return oth.visitO!(
                (String s) => v == s.val,
                () => false);
        }

        bool toBool(String v) { return v.val != ""; }
    }
}


