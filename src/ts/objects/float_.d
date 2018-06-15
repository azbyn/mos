module ts.objects.float_;

import ts.objects;
import ts.stdlib;
import ts.ast.token;
import stdd.conv : to;
import stdd.format;

mixin TSModule!(ts.objects.float_);

@tsexport struct Float {
    tsfloat val;

static:
    __gshared TypeMeta typeMeta;
    enum tsstring type = "float";
    @tsexport {
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

        tsstring toString(tsfloat f) { return f.to!tsstring; }
        Obj opAdd(Pos p, tsfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a + i.val),
                (Float f) => obj!Float(a + f.val),
                () => nil,
            )();
        }
        Obj opSub(Pos p, tsfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a + i.val),
                (Float f) => obj!Float(a + f.val),
                () => nil,
            )();
        }
        Obj opMply(Pos p, tsfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a * i.val),
                (Float f) => obj!Float(a * f.val),
                () => nil,
            )();
        }
        Obj opDiv(Pos p, tsfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a / i.val),
                (Float f) => obj!Float(a / f.val),
                () => nil,
            )();
        }
        Obj opIntDiv(Pos p, tsfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Int((a / i.val).to!tsint),
                (Float f) => obj!Int((a / f.val).to!tsint),
                () => nil,
            )();
        }
        Obj opMod(Pos p, tsfloat a, Obj b) {
            return b.visitO!(
                (Int i) => obj!Float(a % i.val),
                (Float f) => obj!Float(a % f.val),
                () => nil,
            )();
        }
        Obj opPow(Pos p, tsfloat a, Obj b) {
            import stdd.math;
            return b.visitO!(
                (Int i) => obj!Float(pow(a, i.val)),
                (Float f) => obj!Float(pow(a, f.val)),
                () => nil,
            )();
        }

        Obj opCmp(Pos p, tsfloat a, Obj b){
            Obj impl(T)(T o){
                return obj!Int(a == o.val ? 0 : (a < o.val ? -1 : 1));
            }
            return b.visitO!(
                (Int i) => impl(i),
                (Float f) => impl(f),
                () => nil,
            )();
        }
        Obj opEquals(Pos p, tsfloat a, Obj b) {
            Obj impl(T)(T o) { return obj!Bool(a == o.val); }
            return b.visitO!(
                (Int i) => impl(i),
                (Float f) => impl(f),
                () => nil,
            )();
        }
        tsfloat opPlus (tsfloat a) { return a; }
        tsfloat opMinus(tsfloat a) { return -a; }

        bool toBool(tsfloat f) { return f != 0; }
    }
}


