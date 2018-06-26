module mos.misc;

import mos.ast.token : mosstring;
import mos.types;

enum FuncType {
    Default,
    Getter,
    Setter,
}

mosstring mosformat(mosstring fmt, A...)(A args) {
    import stdd.format;

    /*static foreach(i,a;args) {
        static if (__traits(compiles, "a.toStr")){
            args[i] = a.toStr;
        }
        }*/
    //if compiles a.toStr then a to str
    return stdd.format.format!fmt(args);
}

T throwRtrn(T, Ex, A...)(A args, string file = __FILE__, size_t line = __LINE__) {
    throw new Ex(args, file, line);
}

bool contains(T)(T[] arr, T val) {
    foreach (ref t; arr)
        if (t == val)
            return true;
    return false;
}


mosint parseHex(F)(mosstring str, F onFail) {
    mosint r = 0;
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

mosint parseOctal(F)(mosstring str, F onFail) {
    mosint r = 0;
    foreach (c; str) {
        if (c >= '0' && c <= '7')
            r = r << 3 | (c - '0');
        else
            return onFail();
    }
    return r;
}

mosint parseBinary(F)(mosstring str, F onFail) {
    mosint r = 0;
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

    void mosattr();
    void mosattr(ubyte flags, uint fg, uint bg);
    void mosputs(const ushort* sh, size_t len);
    void mosputnl();
    void mosclear();

    ubyte mosGetFlags();
    void mosSetFlags(ubyte v);
    uint mosGetBg();
    void mosSetBg(uint v);
    uint mosGetFg();
    void mosSetFg(uint v);
}
void mosputs(mosstring s) {
    mosputs(cast(ushort*) s.ptr, s.length);
}
void mosputs(A...)(A a) {
    static foreach (k; a) {
        static if (is(k == mosstring))
            mosputs(k);
        else
            mosputs(k.toStr);
    }
}

void mosputsln(mosstring s) {
    mosputs(s ~ '\n');
}
