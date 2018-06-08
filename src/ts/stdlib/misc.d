module ts.stdlib.misc;

import ts.objects;
import ts.builtin;

import stdd.format;

//import stdd.string;

private:

import stdd.random;

__gshared Mt19937_64 gen;

public:

void init() {
    gen.seed(unpredictableSeed);
}

tsstring type(Obj a) {
    return a.type;
}

Obj invalidType(Pos p, tsstring expected, tsstring got) {
    throw new RuntimeException(p, format!"Expected type %s, got %s"(expected, got));
}

Obj invalidArgc(Pos p, tsint expected, tsint got) {
    throw new RuntimeException(p, format!"Expected %d args, got %s"(expected, got));
}

Obj invalidArgcRange(Pos p, tsint min, tsint max, tsint got) {
    throw new RuntimeException(p, format!"Expected between %d and %s args, got %s"(min, max, got));
}

void assert_(Pos p, Env e, Obj v, Obj[] args) {
    if (v.toBool(p, e))
        return;
    if (args.length == 0) {
        throw new RuntimeException(p, format!"assertion failed with value '%s'"(v.toString));
    }
    else if (args.length == 1) {
        throw new RuntimeException(p, format!"%s (%s)"(args[0].get!tsstring(p), v.toString));
    }
    invalidArgcRange(p, 1, 2, args.length);
}
void srand(tsint seed) {
    gen.seed(seed);
}

tsint randSeed() {
    return unpredictableSeed;
}

tsfloat rand() {
    return uniform01(gen); // rand();
}

Obj randrange(Pos p, Obj[] args) {
    //dfmt off
    if (args.length == 1) {
        return args[0].val.tryVisit!(
            (Int i) => toObj(uniform(0, i.val, gen)),
            (Float f) => toObj(uniform(0, f.val, gen)),
            () => invalidType(p,
                "int or float", args[0].type));
    }
    else if (args.length == 2) {
        return args[0].val.tryVisit!(
                (Int a) => args[1].val.tryVisit!(
                    (Int b) => toObj(uniform(a.val, b.val, gen)),
                    (Float b) => toObj(uniform(a.val, b.val, gen)),
                    () => invalidType(p, "int or float", args[1].type)),
                (Float a) => args[1].val.tryVisit!(
                    (Int b) => toObj(uniform(a.val, b.val, gen)),
                    (Float b) => toObj(uniform(a.val, b.val, gen)),
                    () => invalidType(p, "int or float", args[1].type)),
                () => invalidType(p, "int or float", args[0].type));
    }
    else {
        return invalidArgcRange(p, 1, 2, args.length);
    }
    //dfmt on
}
tsint hash_(Obj o) {
    return o.toHash();
}
