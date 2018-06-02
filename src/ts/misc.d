module ts.misc;

import ts.ast.token : tsstring;
import ts.types;

enum FuncType {
    Default,
    Getter,
    Setter,
}

tsstring tsformat(tsstring fmt, A...)(A args) {
    import stdd.format;

    /*static foreach(i,a;args) {
        static if (__traits(compiles, "a.toStr")){
            args[i] = a.toStr;
        }
        }*/
    //if compiles a.toStr then a to str
    return stdd.format.format!fmt(args);
}

T throwRtrn(T, Ex, A...)(A args) {
    throw new Ex(args, __FILE__, __LINE__);
}

bool contains(T)(T[] arr, T val) {
    foreach (ref t; arr)
        if (t == val)
            return true;
    return false;
}

class TSException : Exception {
    import ts.ast.token : Pos;

    Pos pos;
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        this.pos = pos;
        super(msg, file, line);
    }
}

tsint parseHex(F)(tsstring str, F onFail) {
    tsint r = 0;
    foreach (c; str) {
        if (c >= '0' && c <= '9')
            r = r << 4 | (c - '0');
        else if (c >= 'a' && c <= 'f')
            r = r << 4 | (c - 'a' + 10);
        else if (c >= 'A' && c <= 'F')
            r = r << 4 | (c - 'A' + 10);
        else
            return onFail();
    }
    return r;
}

tsint parseOctal(F)(tsstring str, F onFail) {
    tsint r = 0;
    foreach (c; str) {
        if (c >= '0' && c <= '7')
            r = r << 3 | (c - '0');
        else
            return onFail();
    }
    return r;
}

tsint parseBinary(F)(tsstring str, F onFail) {
    tsint r = 0;
    foreach (c; str) {
        if (c == '0' || c == '1')
            r = r << 1 | (c - '0');
        else
            return onFail();
    }
    return r;
}

extern (C++) {

    enum Attr : ubyte {
        Default = 0,
        Bold = 1 << 1,
        Italic = 1 << 2,
        Underline = 1 << 3,

        Newline = 1 << 7,
    }

    enum Color {
        Base00 = 0,
        Base01 = 1,
        Base02 = 2,
        Base03 = 3,
        Base04 = 4,
        Base05 = 5,
        Base06 = 6,
        Base07 = 7,
        Base08 = 8,
        Base09 = 9,
        Base0A = 10,
        Base0B = 11,
        Base0C = 12,
        Base0D = 13,
        Base0E = 14,
        Base0F = 15,

        Black = 0,
        Background = 0,
        Default = 5,
        DarkGrey = 1,
        LightGrey = 3,
        White = 7,
        Red = 8,
        Orange = 9,
        Yellow = 10,
        Green = 11,
        Cyan = 12,
        Blue = 13,
        Purple = 14,
        Brown = 15,
    }

    void tsattr();
    void tsattr(ubyte flags, uint fg, uint bg);
    void tsattr(ubyte flags, Color fg, Color bg);
    void tsputs(const ushort* sh, size_t len);
    void tsputnl();
    void tsclear();
}
void tsputs(tsstring s) {
    tsputs(cast(ushort*) s.ptr, s.length);
}
void tsputsred(tsstring s) {
    tsattr(Attr.Bold | Attr.Underline, Color.Red, Color.Blue);
    tsputs(s);
    tsattr();
}

void tsputs(A...)(A a) {
    static foreach (k; a) {
        static if (is(k == tsstring))
            tsputs(k);
        else
            tsputs(k.toStr);
    }
}

void tsputsln(tsstring s) {
    tsputs(s ~ '\n');
}
