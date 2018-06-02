module ts.stdlib.math;

import ts.stdlib.misc : invalidType, invalidArgc, invalidArgcRange;
import ts.objects;
import stdd.math;
import stdd.format;

//enum tsfloat pi = PI;
private:
Obj toObj(T)(T t) {
    //dfmt off
    static if (is(T==Obj)) return t;
    else static if (is(T==tsint)) return objInt(t);
    else static if (is(T==bool)) return objBool(t);
    else static if (is(T==tsfloat)) return objFloat(t);
    else static if (is(T==tsstring)) return objString(t);
    else static if (is(T==Obj[Obj])) return objMap(t);
    else static if (is(T==real)) return objFloat(t);
    else return new Obj(t);
    //dfmt on
}

tsfloat toFloat(Obj x, Pos p) {
    return x.val.tryVisit!((Int i) => cast(tsfloat) i.val,
                           (Float f) => f.val,
                           () { invalidType(p, "int or float", x.type); return -1; });
}
auto toVal(Obj x, Pos p) {
    return x.val.tryVisit!((Int i) => i.val,
                           (Float f) => f.val,
                           () { invalidType(p, "int or float", x.type); return -1; });
}
mixin template CheckCompiles(string code) {
    static if (!__traits(compiles, code)){
        static assert("invalid code");
    } else {
        mixin(code);
    }
}

mixin template Arg1ToFloat(string name, string f = name) {
    //pragma(msg, "arg1toFloat:"~name);
    mixin(format!`Obj %s_(Pos p, Obj x) {
        return toObj(%s(x.toFloat(p)));
    }`(name, f));
}
mixin template Arg1ToVal(string name, string f = name) {
    //pragma(msg, "arg1toVal:"~name);
    mixin(format!`Obj %s_(Pos p, Obj x) {
        return toObj(%s(x.toVal(p)));
    }`(name, f));
}
mixin template Arg2ToFloat(string name, string f = name) {
    //pragma(msg, "arg2toFloat:"~name);
    mixin(format!`Obj %s_(Pos p, Obj a, Obj b) {
        return toObj(%s(a.toFloat(p), b.toFloat(p)));
    }`(name, f));
}
mixin template Arg2ToVal(string name, string f = name) {
    //pragma(msg, "arg2toVal:"~name);
    mixin(format!`Obj %s_(Pos p, Obj a, Obj b) {
        return toObj(%s(a.toVal(p), b.toVal(p)));
    }`(name, f));
}
public:
tsfloat Prop_Pi() {
    return PI;
}
tsfloat Prop_E() {
    return E;
}
tsfloat Prop_Infinity() {
    return tsfloat.infinity;
}

mixin Arg1ToFloat!"ceil";
mixin Arg1ToFloat!"floor";
mixin Arg1ToFloat!"round";
mixin Arg2ToFloat!"copysign";
mixin Arg1ToFloat!"fabs";
mixin Arg1ToVal!"abs";
mixin Arg2ToFloat!"fmod";
Obj frexp_(Pos p, Obj x) {
    int exp;
    tsfloat m = frexp(x.toFloat(p), exp);
    return objTuple([ objFloat(m), objInt(exp) ]);
}
mixin Arg1ToVal!("isinf", "isInfinity");
mixin Arg1ToVal!("isnan", "isNaN");
tsfloat ldexp_(Pos p, Obj x, tsint exp) {
    return ldexp(x.toFloat(p), cast(int) exp);
}
Obj modf_(Pos p, Obj x) {
    real i;
    tsfloat f = modf(x.toFloat(p), i);
    return objTuple([ objFloat(f), objFloat(i) ]);
}
mixin Arg1ToVal!"trunc";

mixin Arg1ToFloat!"exp";
mixin Arg1ToFloat!"expm1";
mixin Arg1ToFloat!"log";
tsfloat log_(Pos p, Obj x, Obj base) {
    return log(x.toFloat(p)) / log(base.toFloat(p));
}
mixin Arg1ToFloat!"log1p";
mixin Arg1ToFloat!"log10";
mixin Arg2ToFloat!"pow";
mixin Arg1ToFloat!"sqrt";
mixin Arg1ToFloat!"cbrt";



mixin Arg1ToFloat!"acos";
mixin Arg1ToFloat!"asin";
mixin Arg1ToFloat!"atan";
mixin Arg2ToFloat!"atan2";
mixin Arg1ToFloat!"cos";
mixin Arg2ToFloat!"hypot";
mixin Arg1ToFloat!"sin";
mixin Arg1ToFloat!"tan";
tsfloat deg2rad(Pos p, Obj x) {
    return x.toFloat(p) * 180 / PI;
}
tsfloat rad2deg(Pos p, Obj x) {
    return x.toFloat(p) * PI/ 180;
}
mixin Arg1ToFloat!"acosh";
mixin Arg1ToFloat!"asinh";
mixin Arg1ToFloat!"atanh";
mixin Arg1ToFloat!"cosh";
mixin Arg1ToFloat!"sinh";
mixin Arg1ToFloat!"tanh";

Obj min_(Pos p, Obj x, Obj y) {
    auto a = x.toVal(p);
    auto b = y.toVal(p);
    return toObj(a < b ? a : b);
}
Obj max_(Pos p, Obj x, Obj y) {
    auto a = x.toVal(p);
    auto b = y.toVal(p);
    return toObj(a < b ? b : a);
}
mixin Arg1ToVal!"sgn";
bool approxEq(Pos p, Obj x, Obj y, Obj diff) {
    return approxEqual(x.toFloat(p), y.toFloat(p), diff.toFloat(p));
}
bool approxEq(Pos p, Obj x, Obj y) {
    return approxEqual(x.toFloat(p), y.toFloat(p), 1e-05);
}

