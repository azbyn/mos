module mos.objects.float_;

import mos.objects;
import mos.stdlib;
import mos.ast.token;
import stdd.conv : to;
import stdd.format;

mixin MOSModule!(mos.objects.float_);

@mosexport struct Float {
    mosfloat val;

static:
    mixin MOSType!"float";
    @mosexport {
        void ctor(Float v) { v.val = 0; }
        void ctor(Pos p, Float v, Obj o) {
            //dfmt off
            o.visitO!(
                (Int i) { v.val = i.val; },
                (Float f) { v.val = f.val; },
                (String s) {
                    if (s.val.formattedRead!"%f"(v.val) == 0) {
                        throw new RuntimeException(p, format!"Can't parse '%s' to a float"(s.val));
                    }
                },
                () { invalidType(p, "int, float or string", o.typestr); }
            )();
            //dfmt on
        }

        mosstring toString(mosfloat f) { return f.to!mosstring; }
        Obj opAdd(Pos p, mosfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a + i.val),
                (Float f) => obj!Float(a + f.val),
                () => nil,
            )();
        }
        Obj opSub(Pos p, mosfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a + i.val),
                (Float f) => obj!Float(a + f.val),
                () => nil,
            )();
        }
        Obj opMply(Pos p, mosfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a * i.val),
                (Float f) => obj!Float(a * f.val),
                () => nil,
            )();
        }
        Obj opDiv(Pos p, mosfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a / i.val),
                (Float f) => obj!Float(a / f.val),
                () => nil,
            )();
        }
        Obj opIntDiv(Pos p, mosfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int((a / i.val).to!mosint),
                (Float f) => obj!Int((a / f.val).to!mosint),
                () => nil,
            )();
        }
        Obj opMod(Pos p, mosfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a % i.val),
                (Float f) => obj!Float(a % f.val),
                () => nil,
            )();
        }
        Obj opPow(Pos p, mosfloat a, Obj b) {
            import stdd.math;
            return b.visitO!(
                (Int i) => obj!Float(pow(a, i.val)),
                (Float f) => obj!Float(pow(a, f.val)),
                () => nil,
            )();
        }

        Obj opCmp(Pos p, mosfloat a, Obj b){
            Obj impl(T)(T o){
                return obj!Int(a == o.val ? 0 : (a < o.val ? -1 : 1));
            }
            return b.visitO!(
                (Int i) => impl(i),
                (Float f) => impl(f),
                () => nil,
            )();
        }
        Obj opEquals(Pos p, mosfloat a, Obj b) {
            Obj impl(T)(T o) { return obj!Bool(a == o.val); }
            return b.visitO!(
                (Int i) => impl(i),
                (Float f) => impl(f),
                () => nil,
            )();
        }
        mosfloat opPlus (mosfloat a) { return a; }
        mosfloat opMinus(mosfloat a) { return -a; }

        bool toBool(mosfloat f) { return f != 0; }
    }
}


