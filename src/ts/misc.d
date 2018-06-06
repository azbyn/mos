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
extern (C++, colors) {
    alias QRgb = uint;
    QRgb base00();
    QRgb base01();
    QRgb base02();
    QRgb base03();
    QRgb base04();
    QRgb base05();
    QRgb base06();
    QRgb base07();
    QRgb base08();
    QRgb base09();
    QRgb base0A();
    QRgb base0B();
    QRgb base0C();
    QRgb base0D();
    QRgb base0E();
    QRgb base0F();
}
extern (C++) {

    enum Attr : ubyte {
        Default = 0,
        Bold = 1 << 1,
        Italic = 1 << 2,
        Underline = 1 << 3,

        Newline = 1 << 7,
    }

    void tsattr();
    void tsattr(ubyte flags, uint fg, uint bg);
    void tsputs(const ushort* sh, size_t len);
    void tsputnl();
    void tsclear();

    ubyte tsGetFlags();
    void tsSetFlags(ubyte v);
    uint tsGetBg();
    void tsSetBg(uint v);
    uint tsGetFg();
    void tsSetFg(uint v);
}
void tsputs(tsstring s) {
    tsputs(cast(ushort*) s.ptr, s.length);
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
