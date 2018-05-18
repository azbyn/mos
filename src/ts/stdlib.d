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
