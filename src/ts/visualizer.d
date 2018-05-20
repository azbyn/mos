module ts.visualizer;

import ts.ast.token;
import ts.misc;

import stdd.range;

tsstring visualizeError(const(Token)[] toks, size_t pos, string msg) {
    return tsformat!"%s\n%s"(msg, visualizeArrow(toks, pos));
}
tsstring visualizeArrow(const(Token)[] toks, size_t pos) {
    if (pos < 0 || pos >= toks.length)
        return tsformat!"index %s"(pos);
    ptrdiff_t a, b;
    for (a = pos - 1; a > 0; --a) {
        if (toks[a].type == TT.newLine) {
            ++a;
            break;
        }
    }
    size_t len = toks.length;
    for (b = pos + 1; b < len; ++b) {
        if (toks[b].type == TT.newLine)
            break;
    }
    if (a < 0) a = 0;
    if (b >= len) b= len-1;
    //writefln("len = %d, pos = %s, a= %d, b=%d", len, pos, a, b);

    return visualizeArrow(toks[a..b], toks.ptr + pos);
}
private tsstring visualizeArrow(const Token[] toks, const Token* pos) {
    enum tschar space = ' ';
    tsstring res = "";
    auto level = 0;
    auto ptr = toks.ptr;
    auto end = ptr + toks.length;
    size_t arrowPoint = 0;
    for ( ; ptr != end; ++ptr) {
        if (ptr == pos) arrowPoint = res.length;
        auto str = ptr.toStr();
        res ~= str;
    }
    res ~= "\n" ~ repeat(space, arrowPoint).array ~ "^";
    return res;
}

