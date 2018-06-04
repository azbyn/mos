module ts.types;
import stdd.format;

struct Pos {
pure nothrow @nogc @safe:
    this(ptrdiff_t x) {
        i = x;
    }

    ptrdiff_t i;
    alias i this;
} //make it mangle differently to int


version (D_LP64) { // (void*).sizeof == 8
    alias tsfloat = double;
    alias tsint = long;
}
else {
    alias tsfloat = float;
    alias tsint = int;
}
alias tschar = wchar;
alias tsstring = immutable(tschar)[];

class TSException : Exception {
    import ts.ast.token : Pos;

    Pos pos;
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        this.pos = pos;
        super(msg, file, line);
    }
}
