module mos.objects.int_;

import mos.objects;
import mos.stdlib;
import stdd.conv : to;
import stdd.format;
import stdd.variant;

mixin MOSModule!(mos.objects.int_);
//dfmt off
@mosexport struct Int {
    mosint val;
static:
    mixin MOSType!"int";
    @mosexport {
        void ctor(Int v) { v.val = 0; }
        void ctor(Pos p, Int v, Obj o) {
            o.visitO!(
                (Int i) { v.val = i.val; },
                (Float f) { v.val = f.val.to!mosint; },
                (String s) {
                    if (s.val.formattedRead!"%d"(v.val) == 0) {
                        throw new RuntimeException(p, format!"Can't parse '%s' to an int"(s.val));
                    }
                },
                () { invalidType(p, "int, float or string", o.typestr); }
            );
        }

        mosstring toString(mosint i) { return i.to!mosstring; }
        Obj opAdd(Pos p, mosint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int(a + i.val),
                (Float f) => obj!Float(a + f.val),
                () => nil,
            );
        }
        Obj opSub(Pos p, mosint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int(a - i.val),
                (Float f) => obj!Float(a - f.val),
                () => nil,
            );
        }
        Obj opMply(Pos p, mosint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int(a * i.val),
                (Float f) => obj!Float(a * f.val),
                () => nil,
            );
        }
        Obj opDiv(Pos p, mosint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a.to!mosfloat / i.val),
                (Float f) => obj!Float(a / f.val),
                () => nil,
            );
        }
        Obj opIntDiv(Pos p, mosint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int(a / i.val),
                (Float f) => obj!Int(a / f.val.to!mosint),
                () => nil,
            );
        }
        Obj opMod(Pos p, mosint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int(a % i.val),
                (Float f) => obj!Float(a % f.val),
                () => nil,
            );
        }
        Obj opPow(Pos p, mosint a, Obj b) {
            import stdd.math;
            return b.visitO!(
                (Int i) => obj!Int(pow(a, i.val)),
                (Float f) => obj!Float(pow(a, f.val)),
                () => nil,
            );
        }
        Obj opCmp(Pos p, mosint a, Obj b){
            Obj impl(T)(T o){
                return obj!Int(a == o.val ? 0 : (a < o.val ? -1 : 1));
            }
            return b.visitO!(
                (Int i) => impl(i),
                (Float f) => impl(f),
                () => nil,
            );
        }
        Obj opEquals(Pos p, mosint a, Obj b) {
            Obj impl(T)(T o) { return obj!Bool(a == o.val); }
            return b.visitO!(
                (Int i) => impl(i),
                (Float f) => impl(f),
                () => nil,
            );
        }
        mosint opPlus(mosint a) { return a; }
        mosint opMinus(mosint a) { return -a; }
        mosint opCom(mosint a) { return ~a; }
        mosint opXor(mosint a, mosint b) { return a^b; }
        mosint opAnd(mosint a, mosint b) { return a&b; }
        mosint opOr (mosint a, mosint b) { return a|b; }
        mosint opLsh(mosint a, mosint b) { return a<<b;}
        mosint opRsh(mosint a, mosint b) { return a>>b; }

        mosint opInc(mosint i) { return i + 1; }
        mosint opDec(mosint i) { return i - 1; }

        bool toBool(mosint i) { return i != 0; }
    }

}
