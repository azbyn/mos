module ts.objects.float_;

import ts.objects;
import ts.stdlib;
import ts.ast.token;
import stdd.conv : to;
import stdd.format;

struct Float {
    tsfloat val;

static:
    void ctor(Float v) { v.val = 0; }
    void ctor(Pos p, Env e, Float v, Obj o) {
        //dfmt off
        o.val.tryVisit!(
            (Int i) { v.val = i.val; },
            (Float f) { v.val = f.val; },
            (String s) {
                if (s.val.formattedRead!"%f"(v.val) == 0) {
                    throw new RuntimeException(p, format!"Can't parse '%s' to a float"(s.val));
                }
            },
            () { invalidType(p, e, "int, float or string", o.type); }
        )();
        //dfmt on
    }

    tsstring toString(tsfloat f) { return f.to!tsstring; }
    tsstring type() { return "float"; }
    Obj opAdd(Pos p, Env e, tsfloat a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objFloat(a + i.val),
            (Float f) => objFloat(a + f.val),
            () => nil,
        )();
    }
    Obj opSub(Pos p, Env e, tsfloat a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objFloat(a + i.val),
            (Float f) => objFloat(a + f.val),
            () => nil,
        )();
    }
    Obj opMply(Pos p, Env e, tsfloat a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objFloat(a * i.val),
            (Float f) => objFloat(a * f.val),
            () => nil,
        )();
    }
    Obj opDiv(Pos p, Env e, tsfloat a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objFloat(a / i.val),
            (Float f) => objFloat(a / f.val),
            () => nil,
        )();
    }
    Obj opIntDiv(Pos p, Env e, tsfloat a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objInt((a / i.val).to!tsint),
            (Float f) => objInt((a / f.val).to!tsint),
            () => nil,
        )();
    }
    Obj opMod(Pos p, Env e, tsfloat a, Obj b) {
        return b.val.tryVisit!(
            (Int i) => objFloat(a % i.val),
            (Float f) => objFloat(a % f.val),
            () => nil,
        )();
    }
    Obj opPow(Pos p, Env e, tsfloat a, Obj b) {
        import stdd.math;
        return b.val.tryVisit!(
            (Int i) => objFloat(pow(a, i.val)),
            (Float f) => objFloat(pow(a, f.val)),
            () => nil,
        )();
    }

    Obj opCmp(Pos p, Env e, tsfloat a, Obj b){
        Obj impl(T)(T o){
            return objInt(a == o.val ? 0 : (a < o.val ? -1 : 1));
        }
        return b.val.tryVisit!(
            (Int i) => impl(i),
            (Float f) => impl(f),
            () => nil,
        )();
    }
    Obj opEq(Pos p, Env e, tsfloat a, Obj b) {
        Obj impl(T)(T o) { return objBool(a == o.val); }
        return b.val.tryVisit!(
            (Int i) => impl(i),
            (Float f) => impl(f),
            () => nil,
        )();
    }
    tsfloat opPlus (tsfloat a) { return a; }
    tsfloat opMinus(tsfloat a) { return -a; }



    bool toBool(tsfloat f) { return f != 0; }
}


