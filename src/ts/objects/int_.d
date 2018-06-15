module ts.objects.int_;

import ts.objects;
import ts.stdlib;
import stdd.conv : to;
import stdd.format;
import stdd.variant;

mixin TSModule!(ts.objects.int_);
//dfmt off
@tsexport struct Int {
    tsint val;
static:
    __gshared TypeMeta typeMeta;
    enum tsstring type = "int";
    @tsexport {
        void ctor(Int v) { v.val = 0; }
        void ctor(Pos p, Int v, Obj o) {
            o.visitO!(
                (Int i) { v.val = i.val; },
                (Float f) { v.val = f.val.to!tsint; },
                (String s) {
                    if (s.val.formattedRead!"%d"(v.val) == 0) {
                        throw new RuntimeException(p, format!"Can't parse '%s' to an int"(s.val));
                    }
                },
                () { invalidType(p, "int, float or string", o.typestr); }
            );
        }

        tsstring toString(tsint i) { return i.to!tsstring; }
        Obj opAdd(Pos p, tsint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int(a + i.val),
                (Float f) => obj!Float(a + f.val),
                () => nil,
            );
        }
        Obj opSub(Pos p, tsint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int(a - i.val),
                (Float f) => obj!Float(a - f.val),
                () => nil,
            );
        }
        Obj opMply(Pos p, tsint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int(a * i.val),
                (Float f) => obj!Float(a * f.val),
                () => nil,
            );
        }
        Obj opDiv(Pos p, tsint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a.to!tsfloat / i.val),
                (Float f) => obj!Float(a / f.val),
                () => nil,
            );
        }
        Obj opIntDiv(Pos p, tsint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int(a / i.val),
                (Float f) => obj!Int(a / f.val.to!tsint),
                () => nil,
            );
        }
        Obj opMod(Pos p, tsint a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int(a % i.val),
                (Float f) => obj!Float(a % f.val),
                () => nil,
            );
        }
        Obj opPow(Pos p, tsint a, Obj b) {
            import stdd.math;
            return b.visitO!(
                (Int i) => obj!Int(pow(a, i.val)),
                (Float f) => obj!Float(pow(a, f.val)),
                () => nil,
            );
        }
        Obj opCmp(Pos p, tsint a, Obj b){
            Obj impl(T)(T o){
                return obj!Int(a == o.val ? 0 : (a < o.val ? -1 : 1));
            }
            return b.visitO!(
                (Int i) => impl(i),
                (Float f) => impl(f),
                () => nil,
            );
        }
        Obj opEquals(Pos p, tsint a, Obj b) {
            Obj impl(T)(T o) { return obj!Bool(a == o.val); }
            return b.visitO!(
                (Int i) => impl(i),
                (Float f) => impl(f),
                () => nil,
            );
        }
        tsint opPlus(tsint a) { return a; }
        tsint opMinus(tsint a) { return -a; }
        tsint opCom(tsint a) { return ~a; }
        tsint opXor(tsint a, tsint b) { return a^b; }
        tsint opAnd(tsint a, tsint b) { return a&b; }
        tsint opOr (tsint a, tsint b) { return a|b; }
        tsint opLsh(tsint a, tsint b) { return a<<b;}
        tsint opRsh(tsint a, tsint b) { return a>>b; }

        tsint opInc(tsint i) { return i + 1; }
        tsint opDec(tsint i) { return i - 1; }

        bool toBool(tsint i) { return i != 0; }
    }

}
