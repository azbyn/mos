module ts.stdlib.io;

import ts.objects;
import ts.stdlib.misc : invalidType, invalidArgc, invalidArgcRange;
import ts.misc;
import stdd.array;

private enum formatChar = '@';

tsstring sprintf(Pos pos, tsstring fmt, Obj[] args) {
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
        invalidArgc(pos, argc, expectedArgc);
    return res;
}

void print(Obj[] args) {
    foreach (a; args)
        tsputs(a);
}
void printred(Obj[] args) {
    foreach (a; args)
        tsputsred(a.toStr);
}
void println(Obj[] args) {
    print(args);
    tsputs("\n");
}
void printf(Pos p, tsstring fmt, Obj[] args) {
    tsputs(sprintf(p, fmt, args));
}
void printfln(Pos p, tsstring fmt, Obj[] args) {
    tsputsln(sprintf(p, fmt, args));
}
