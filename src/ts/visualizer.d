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
private tsstring visualizeArrow(const(Token)[] toks, const(Token)* pos) {
    return Visualizer().visualize(toks, pos);
}

struct Visualizer {
private:
    const(Token)* ptr;
    const(Token)* end;
    int level = 0;
    tsstring res;
    const(Token)* pos;
    size_t arrowPoint;
    size_t asciiLen;
    enum space = cast(tschar) ' ';
    public tsstring visualize(const(Token)[] toks, const(Token)* pos) {
        res = "";
        level = 0;
        ptr = toks.ptr;
        end = ptr + toks.length;
        this.pos = pos;
        while (!isEof()) {
            statement();
        }
        res ~= "\n" ~ repeat(space, arrowPoint).array ~ "^";
        return res;
    }

    bool isEof() {
        return ptr >= end;
    }
    TT prevType() {
        return ptr > end ? TT.eof : (ptr-1).type;
    }
    TT type() {
        return isEof() ? TT.eof : ptr.type;
    }
    TT nextType() {
        return ptr + 1 >= end ? TT.eof : (ptr+1).type;
    }

    bool consume(TT[] args...) {
        auto t = type();
        foreach (a; args){
            if (a == t) {
                ++ptr;
                return true;
            }
        }
        return false;
    }
    tsstring colorize() {
        if (ptr == pos)
            arrowPoint = res.length;
        return ptr.toStr;
    }
    tsstring getIndent() {
        return repeat(space, level*2).array;
    }

    void parenthesis() {
        int lvl = 0;
        while (!isEof()) {
            res ~= colorize();
            if (consume(TT.lParen, TT.lSquare, TT.lCurly)) ++lvl;
            else if (consume(TT.rParen, TT.rSquare, TT.rCurly)) --lvl;
            else ++ptr;
            if (lvl <= 0) break;
        }
    }
    void statement() {
        if(isEof()) return;
        auto col = colorize();
        if (consume(TT.if_, TT.else_, TT.while_, TT.for_)) {
            res ~= col;
            ++level;
            parenthesis();
            auto col1 = colorize();
            if (consume(TT.lCurly)) {
                res ~= " " ~ col1;
                while (!isEof()) {
                    if (consume(TT.rCurly)) {
                        --level;
                        res ~= getIndent() ~ "}";
                        break;
                    }
                    statement();
                }
            }
            else {
                while (consume(TT.newLine)) res ~= "\n";
                statement();
                --level;
            }
        }
        else {
            res ~= colorize();
            if (consume(TT.lParen, TT.lSquare, TT.lCurly)) ++level;
            else if (consume(TT.rParen, TT.rSquare, TT.rCurly)) --level;
            else ++ptr;
        }
    }
}
