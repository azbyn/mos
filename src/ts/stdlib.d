module ts.stdlib;

import ts.objects;
import ts.builtin;
import ts.misc;

import stdd.format;

//import stdd.string;
import stdd.math;
import stdd.array;

private:

enum formatChar = '@';
import stdd.random;

__gshared Mt19937_64 gen;

public:

void __init() {
    gen.seed(unpredictableSeed);
}

tsstring type(Obj a) {
    return a.type;
}

Obj invalidType(Pos p, Env e, tsstring expected, tsstring got) {
    throw new RuntimeException(p, format!"Expected type %s, got %s"(expected, got));
}

Obj invalidArgc(Pos p, Env e, tsint expected, tsint got) {
    throw new RuntimeException(p, format!"Expected %d args, got %s"(expected, got));
}

Obj invalidArgcRange(Pos p, Env e, tsint min, tsint max, tsint got) {
    throw new RuntimeException(p, format!"Expected between %d and %s args, got %s"(min, max, got));
}

void assert_(Pos p, Env e, Obj v, Obj[] args) {
    if (v.toBool())
        return;
    if (args.length == 0) {
        throw new RuntimeException(p, format!"assertion failed with value '%s'"(v.toString));
    }
    else if (args.length == 1) {
        throw new RuntimeException(p, format!"%s (%s)"(args[0].get!tsstring(p), v.toString));
    }
    invalidArgcRange(p, e, 1, 2, args.length);
}

//enum tsfloat pi = PI;
tsfloat Pi() {
    return PI;
}
//make more python like
tsfloat abs_(tsfloat v) { return abs(v); }
tsint abs_(tsint v) { return abs(v); }
tsfloat sin_(tsfloat v) { return sin(v); }
tsfloat cos_(tsfloat v) { return cos(v); }
tsfloat tan_(tsfloat v) { return tan(v); }
tsfloat acos_(tsfloat v) { return acos(v); }
tsfloat asin_(tsfloat v) { return asin(v); }
tsfloat atan_(tsfloat v) { return atan(v); }
tsfloat atan2_(tsfloat y, tsfloat x) { return atan2(y, x); }
tsfloat cosh_(tsfloat v) { return cosh(v); }
tsfloat sinh_(tsfloat v) { return sinh(v); }
tsfloat tanh_(tsfloat v) { return tanh(v); }
tsfloat acosh_(tsfloat v) { return acosh(v); }
tsfloat asinh_(tsfloat v) { return asinh(v); }
tsfloat atanh_(tsfloat v) { return atanh(v); }
tsfloat sqrt_(tsfloat v) { return sqrt(v); }
tsfloat exp_(tsfloat v) { return exp(v); }
tsfloat expm1_(tsfloat v) { return expm1(v); }
//tsfloat frexp_(tsfloat v) { return (v); }
//tsfloat ilogb_(tsfloat v) { return ilogb(v); }
tsfloat log_(tsfloat v) { return log(v); }
tsfloat log10_(tsfloat v) { return log10(v); }
tsfloat log1p_(tsfloat v) { return log1p(v); }
tsfloat log2_(tsfloat v) { return log2(v); }
//tsfloat logb_(tsfloat v) { return logb(v); }
tsfloat fmod_(tsfloat x, tsfloat y) { return fmod(x,y); }
//nothrow @nogc @trusted real modf(real x, ref real i);
tsfloat scalbn_(tsfloat x, tsint n) {return scalbn(x, cast(int) n); }
tsfloat cbrt_(tsfloat v) { return cbrt(v); }
tsfloat fabs_(tsfloat v) { return fabs(v); }
tsfloat hypot_(tsfloat x, tsfloat y) { return hypot(x, y); }
tsfloat ceil_(tsfloat x) { return ceil(x); }
tsfloat cbrt_(tsfloat v) { return cbrt(v); }
tsfloat floor_(tsfloat v) { return floor(v); }
tsfloat round_(tsfloat v) { return round(v); }
tsfloat quantize_(tsfloat v, tsfloat unit) { return quantize(v, unit); }
tsfloat nearbyint_(tsfloat v) { return nearbyint(v); }
tsfloat rint_(tsfloat v) { return rint(v); }
tsint iround_(tsfloat v) { return cast(tsint) lround(v); }
tsint irint_(tsfloat v) { return cast(tsint) lrint(v); }
tsfloat remainder_(tsfloat x, tsfloat y) { return remainder(x, y); }
//tsfloat remquo_(tsfloat x, tsfloat y) { return remquo(x, y); }
bool isNaN_(tsfloat x) { return isNaN(x); }
bool isFinite_(tsfloat x) { return isFinite(x); }
bool isNormal_(tsfloat x) { return isNormal(x); }
bool isSubnormal_(tsfloat x) { return isSubnormal(x); }
bool isInfinity_(tsfloat x) { return isInfinity(x); }
bool isIdentical_(tsfloat x, tsfloat y) { return isIdentical(x, y); }
tsint signbit_(tsfloat x) { return signbit(x); }
tsfloat sgn_(tsfloat x) { return sgn(x); }
tsint sgn_(tsint x) { return sgn(x); }
tsfloat pow_(tsfloat x, tsfloat y) { return pow(x, y); }

tsfloat max_(tsfloat x, tsfloat y) { return x> y ? x : y; }
tsfloat max_(tsint x, tsfloat y)   { return x> y ? x : y; }
tsfloat max_(tsfloat x, tsint y)   { return x> y ? x : y; }
tsint max_(tsint x, tsint y)      { return x> y ? x : y; }

tsfloat min_(tsfloat x, tsfloat y) { return x< y ? x : y; }
tsfloat min_(tsint x, tsfloat y)   { return x< y ? x : y; }
tsfloat min_(tsfloat x, tsint y)   { return x< y ? x : y; }
tsint   min_(tsint x, tsint y)     { return x< y ? x : y; }
bool approxEq_(tsfloat x, tsfloat y, tsfloat diff = 1e-05) {return approxEqual(x, y, diff); }

/*
	abs  fabs  sqrt  cbrt  hypot  poly  nextPow2  truncPow2 
Trigonometry	sin  cos  tan  asin  acos  atan  atan2  sinh  cosh  tanh  asinh  acosh  atanh  expi 
Rounding	ceil  floor  round  lround  trunc  rint  lrint  nearbyint  rndtol  quantize 
Exponentiation & Logarithms	pow  exp  exp2  expm1  ldexp  frexp  log  log2  log10  logb  ilogb  log1p  scalbn 
Modulus	fmod  modf  remainder 
Floating-point operations	approxEqual  feqrel  fdim  fmax  fmin  fma  nextDown  nextUp  nextafter  NaN  getNaNPayload  cmp 
Introspection	isFinite  isIdentical  isInfinity  isNaN  isNormal  isSubnormal  signbit  sgn  copysign  isPowerOf2 
Hardware Control	IeeeFlags  FloatingPointControl 
 */

void srand(tsint seed) {
    gen.seed(seed);
}

tsint randSeed() {
    return unpredictableSeed;
}

tsfloat rand() {
    return uniform01(gen); // rand();
}

Obj randrange(Pos p, Env e, Obj[] args) {
    if (args.length == 1) {
        return args[0].val.tryVisit!((Int i) => toObj(uniform(0, i.val, gen)),
                (Float f) => toObj(uniform(0, f.val, gen)), () => invalidType(p,
                    e, "int or float", args[0].type));
    }
    else if (args.length == 2) {
        return args[0].val.tryVisit!(
                (Int a) => args[1].val.tryVisit!((Int b) => toObj(uniform(a.val,
                b.val, gen)), (Float b) => toObj(uniform(a.val, b.val, gen)),
                () => invalidType(p, e, "int or float", args[1].type)),
                (Float a) => args[1].val.tryVisit!((Int b) => toObj(uniform(a.val,
                b.val, gen)), (Float b) => toObj(uniform(a.val, b.val, gen)),
                () => invalidType(p, e, "int or float", args[1].type)),
                () => invalidType(p, e, "int or float", args[0].type));
    }
    else {
        return invalidArgcRange(p, e, 1, 2, args.length);
    }
}

tsstring sprintf(Pos pos, Env env, tsstring fmt, Obj[] args) {
    Obj pop() {
        auto t = args.front();
        args.popFront();
        return t;
    }

    //auto str = pop().get!String(pos).val;
    size_t argc = args.length;
    size_t expectedArgc = 0;

    auto p = fmt.ptr;
    const end = p + fmt.length;
    tsstring res = "";
    for (; p != end; ++p) {
        if (*p != formatChar) {
            res ~= *p;
        }
        else if ((p + 1) != end && *(p + 1) == formatChar) {
            ++p;
            res ~= formatChar;
        }
        else {
            ++expectedArgc;
            if (args.length != 0)
                res ~= pop().toStr;
        }
    }
    if (argc != expectedArgc)
        invalidArgc(pos, env, argc, expectedArgc);
    return res;
}

void print(Obj[] args) {
    foreach (a; args)
        tsputs(a);
}
void println(Obj[] args) {
    print(args);
    tsputs("\n");
}
void printf(Pos p, Env e, tsstring fmt, Obj[] args) {
    tsputs(sprintf(p, e, fmt, args));
}
void printfln(Pos p, Env e, tsstring fmt, Obj[] args) {
    tsputsln(sprintf(p, e, fmt, args));
}
