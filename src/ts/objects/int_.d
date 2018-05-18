module ts.objects.int_;

import ts.objects;
import ts.stdlib;
import stdd.conv : to;
import stdd.format;
import stdd.variant;

//dfmt off
// on 32 bit machines tsint is signed int32 and on 32bit it's int64
struct Int {
    tsint val;
static:
    void ctor(Int v) { v.val = 0; }
    void ctor(Pos p, Env e, Int v, Obj o) {
        o.val.tryVisit!(
            (Int i) { v.val = i.val; },
            (Float f) { v.val = f.val.to!tsint; },
            (String s) {
                if (s.val.formattedRead!"%d"(v.val) == 0) {
                    throw new RuntimeException(p, format!"Can't parse '%s' to an int"(s.val));
                }
            },
            () { invalidType(p, e, "int, float or string", o.type); }
        )();
    }

    tsstring type() { return "int"; }
    tsstring toString(tsint i) { return i.to!tsstring; }
    Obj opAdd(Pos p, Env e, tsint a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objInt(a + i.val),
            (Float f) => objFloat(a + f.val),
            () => nil,
        )();
    }
    Obj opSub(Pos p, Env e, tsint a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objInt(a - i.val),
            (Float f) => objFloat(a - f.val),
            () => nil,
        )();
    }
    Obj opMply(Pos p, Env e, tsint a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objInt(a * i.val),
            (Float f) => objFloat(a * f.val),
            () => nil,
        )();
    }
    Obj opDiv(Pos p, Env e, tsint a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objFloat(a.to!tsfloat / i.val),
            (Float f) => objFloat(a / f.val),
            () => nil,
        )();
    }
    Obj opIntDiv(Pos p, Env e, tsint a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objInt(a / i.val),
            (Float f) => objInt(a / f.val.to!tsint),
            () => nil,
        )();
    }
    Obj opMod(Pos p, Env e, tsint a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objInt(a % i.val),
            (Float f) => objFloat(a % f.val),
            () => nil,
        )();
    }
    Obj opPow(Pos p, Env e, tsint a, Obj b) {
        import stdd.math;
        return b.val.tryVisit!(
            (Int i) => objInt(pow(a, i.val)),
            (Float f) => objFloat(pow(a, f.val)),
            () => nil,
        )();
    }


    Obj opCmp(Pos p, Env e, tsint a, Obj b){
        Obj impl(T)(T o){
            return objInt(a == o.val ? 0 : (a < o.val ? -1 : 1));
        }
        return b.val.tryVisit!(
            (Int i) => impl(i),
            (Float f) => impl(f),
            () => nil,
        )();
    }
    Obj opEq(Pos p, Env e, tsint a, Obj b) {
        Obj impl(T)(T o) { return objBool(a == o.val); }
        return b.val.tryVisit!(
            (Int i) => impl(i),
            (Float f) => impl(f),
            () => nil,
        )();
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
