module ts.stdlib.io;

import ts.objects;
import ts.stdlib.misc : invalidType, invalidArgc, invalidArgcRange;
import ts.misc;
import stdd.array;

private enum formatChar = '@';

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
                res ~= pop().toStr(pos, env);
        }
    }
    if (argc != expectedArgc)
        invalidArgc(pos, argc, expectedArgc);
    return res;
}

void print(Pos p, Env e, Obj[] args) {
    foreach (a; args)
        tsputs(a.toStr(p, e));
}
void printred(Pos p, Env e, Obj[] args) {
    foreach (a; args)
        tsputsred(a.toStr(p, e));
}
void println(Pos p, Env e,Obj[] args) {
    print(p, e,args);
    tsputs("\n");
}
void printf(Pos p, Env e, tsstring fmt, Obj[] args) {
    tsputs(sprintf(p, e, fmt, args));
}
void printfln(Pos p, Env e, tsstring fmt, Obj[] args) {
    tsputsln(sprintf(p, e, fmt, args));
}
