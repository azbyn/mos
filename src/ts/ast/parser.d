module ts.ast.parser;

import stdd.format;
import ts.ast.ast_node;
import ts.ast.token;
import ts.misc;

class ParserException : TSException {
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        super(pos, msg, file, line);
    }
}

struct Parser {

private:

    ParserException expected(TT tt) {
        return expected(tt.symbolicStr);
    }

    ParserException expected(string tt) {
        return new ParserException(pos, format!"Expected %s, found %s"(tt,
                type().symbolicStr), __FILE__, __LINE__);
    }

    const(Token)* ptr;
    const(Token)* begin;
    const(Token)* end;
    struct Error {
        Pos pos;
        string msg;
        string toString() {
            return format!"@%d: %s"(pos, msg);
        }
    }

    public Error[] errors;
    public AstNode[] nodes;

    @property Pos pos() {
        return getPos(ptr);
    }

    Pos getPos(const(Token)* t) {
        return Pos(t - begin);
    }
    /*
    public this(const(Token)[] tokens) {
        parse(tokens);
        }*/

    public bool parse(const(Token)[] tokens) {
        ptr = begin = tokens.ptr;
        end = begin + tokens.length;
        errors = [];
        nodes = [];
        main();
        return errors.length == 0;
    }

    bool isEof() {
        return type() == TT.eof;
    }

    TT type() {
        for (; ptr < end; ++ptr) {
            if (ptr.type != TT.newLine)
                return ptr.type;
        }
        return TT.eof;
    }
    /*
    bool is_(TT tt) {
        return type() == tt;
        }*/

    bool is_(A...)(A args) {
        static if (args.length == 1) {
            return type() == args[0];
        }
        else {
            auto t = type();
            static foreach (a; args)
                if (t == a)
                    return true;
            return false;
        }
    }

    bool consume(A...)(A args) {
        if (is_(args)) {
            ++ptr;
            return true;
        }
        return false;
    }

    bool consume(A...)(out const(Token)* t, A args) {
        if (is_(args)) {
            t = ptr++;
            return true;
        }
        return false;
    }

    void require(TT tt) {
        if (!consume(tt))
            throw expected(tt);
    }

    void require(out const(Token)* t, TT tt) {
        if (!consume(t, tt))
            throw expected(tt);
    }

    AstNode binary(const(Token)* t, AstNode a, AstNode b) {
        return binary(getPos(t), t.type, a, b);
    }

    AstNode binary(Pos pos, TT type, AstNode a, AstNode b) {
        //dfmt off
        switch (type) {
        case TT.lt:
        case TT.gt:
        case TT.le:
        case TT.ge: return astCmp(pos, type, a, b);
        case TT.ne: return unary(pos, TT.not, binary(pos, TT.eq, a, b));
        default: return astBinary(pos, type.binaryFunctionName, a, b);
        }
        //dfmt on
    }

    AstNode unary(const(Token)* t, AstNode a) {
        return unary(getPos(t), t.type, a);
    }

    AstNode unary(Pos pos, TT type, AstNode a) {
        return astMethodCall(pos, type.unaryFunctionName, a, null);
    }

    AstNode leftRecursive(A...)(AstNode function(Parser*) next, A args) {
        auto a = next(&this);
        const(Token)* t;
        for (;;) {
            if (consume(t, args)) {
                a = binary(t, a, next(&this));
            }
            else {
                return a;
            }
        }
    }

    auto expressionSeq(F)(TT terminator, F fun) {
        return expressionSeq(terminator, TT.comma, fun);
    }

    auto expressionSeq(F)(TT terminator, TT separator, F fun) {
        AstNode[] args = [];
        while (!is_(TT.eof, terminator)) {
            args ~= expressionNoComma();
            if (!consume(separator))
                break;
        }
        require(terminator);
        return fun(args);
    }

    static string genLeftRecursive(A...)(string name, string next, A args) {
        auto res = format!`
                    static AstNode %s(Parser* p) {
                        return p.leftRecursive(&%s, `(name, next);
        static foreach (a; args)
            res ~= format!"TT.%s, "(symbolicToTTName(a));
        res ~= "); }";
        return res;
    }

    // main: { statement | ";" }
    void main() {
        while (!isEof()) {
            if (!consume(TT.terminator)) {
                tryStatement(nodes);
            }
        }
    }

    void tryStatement(ref AstNode[] nodes) {
        try {
            nodes ~= statement();
        }
        catch (ParserException e) {
            errors ~= Error(e.pos, e.msg);
            ++ptr;
        }
    }

    // statement: funDef | return | if | while | for | ctrlFlow
    //          | expression ";"
    //          | "{" { statement } "}"
    AstNode statement() {
        const(Token)* t;
        if (!consume(t, TT.lCurly)) {
            AstNode n;
            //dfmt off
            if (funcDef(n)) return n;
            if (return_(n)) return n;
            if (if_(n)) return n;
            if (while_(n)) return n;
            if (for_(n)) return n;
            if (ctrlFlow(n)) return n;
            //dfmt on
            n = expression();
            require(TT.terminator);
            return n;
        }
        AstNode[] nodes;
        while (!is_(TT.rCurly, TT.eof)) {
            tryStatement(nodes);
        }
        require(TT.rCurly);
        return astBody(getPos(t), nodes);
    }
    // return: "return" expression ";"
    bool return_(out AstNode res) {
        const(Token)* t;
        if (!consume(t, TT.return_))
            return false;
        res = astReturn(getPos(t), expression());
        require(TT.terminator);
        return true;
    }
    // ctrlFlow: ("break" | "continue") ";"
    bool ctrlFlow(out AstNode res) {
        const(Token)* t;
        if (!consume(t, TT.break_, TT.continue_))
            return false;
        res = astCtrlFlow(getPos(t), t.type);
        require(TT.terminator);
        return true;
    }

    // funcDef: "fun" Identifier [ "[" funcParams "]" ] "(" funcParams ")" statement
    // funcParams: Identifier ["," [funParams]]
    bool funcDef(out AstNode res) {
        return fun!true(res);
    }
    // fun: "fun" [ "[" funcParams "]" ] "(" funcParams ")" statement
    // funcParams: Identifier ["," [funParams]]
    bool fun(bool isDef = false)(out AstNode res) {
        void funcParams(TT terminator, ref tsstring[] args) {
            const(Token)* p;
            while (!is_(TT.eof, terminator)) {
                require(p, TT.identifier);
                args ~= p.tsstr;
                if (!consume(TT.comma))
                    break;
            }
            require(terminator);
        }

        const(Token)* f;
        if (!consume(f, TT.fun))
            return false;
        static if (isDef) {
            const(Token)* t;
            require(t, TT.identifier);
        }
        tsstring[] captures;
        if (consume(TT.lSquare)) {
            funcParams(TT.rSquare, captures);
        }
        require(TT.lParen);
        tsstring[] params;
        funcParams(TT.rParen, params);
        res = astLambda(getPos(f), captures, params, statement());

        static if (isDef)
            res = astAssign(getPos(t), astVariable(getPos(t), t.tsstr), res);
        return true;
    }
    // if_: "if" "(" expression ")" statement [ "else" statement ]
    bool if_(out AstNode res) {
        const(Token)* t;
        if (!consume(t, TT.if_))
            return false;
        require(TT.lParen);
        auto cond = expression();
        require(TT.rParen);
        auto body_ = statement();
        AstNode else_ = null;
        if (consume(TT.else_))
            else_ = statement();
        res = astIf(getPos(t), cond, body_, else_);
        return true;
    }
    // while_: "while" "(" expression ")" statement
    bool while_(out AstNode res) {
        const(Token)* t;
        if (!consume(t, TT.while_))
            return false;
        require(TT.lParen);
        auto cond = expression();
        require(TT.rParen);
        auto body_ = statement();
        res = astWhile(getPos(t), cond, body_);
        return true;
    }
    // for_: "for" "(" identifier ["," identifier] "in" expression ")" statement
    bool for_(out AstNode res) {
        const(Token)* t;
        if (!consume(t, TT.for_))
            return false;
        require(TT.lParen);
        const(Token)* a;
        const(Token)* b = null;
        require(a, TT.identifier);
        if (consume(TT.comma)) {
            require(b, TT.identifier);
        }
        require(TT.in_);
        auto col = expression();
        require(TT.rParen);
        auto body_ = statement();
        tsstring index, val;
        if (b is null) {
            index = "_";
            val = a.tsstr;
        }
        else {
            index = a.tsstr;
            val = b.tsstr;
        }
        res = astFor(getPos(t), index, val, col, body_);
        return true;
    }

    // expression: comma
    AstNode expression() {
        return comma();
    }
    // comma: [comma ","] assign
    AstNode comma() {
        auto a = assign();
        const(Token)* t;
        for (;;) {
            if (consume(t, TT.comma)) {
                a = astComma(getPos(t), a, assign());
            }
            else
                return a;
        }
    }

    AstNode expressionNoComma() {
        return assign();
    }

    // assign:  ternary | identifier assignOp assign
    // assignOp: "=" | "+=" | "-=" | "/=" | "//=" | "*=" | "%=" |
    //           "**=" | "<<=" | ">>=" | "&=" | "^=" | "|=" | "~="
    AstNode assign() {
        auto a = ternary();
        const(Token)* sgn;
        if (consume(sgn, TT.assign)) {
            return astAssign(getPos(sgn), a, assign());
        }
        else if (consume(sgn, TT.plusEq, TT.minusEq, TT.divEq, TT.intDivEq,
                TT.mplyEq, TT.modEq, TT.powEq, TT.lshEq, TT.rshEq, TT.andEq,
                TT.orEq, TT.xorEq, TT.catEq)) {
            return astAssign(getPos(sgn), a, binary(sgn, a, assign()));
        }
        return a;
    }
    // ternary: boolOp [ "?" expression ":" ternary ]
    AstNode ternary() {
        auto cond = boolOp();
        const(Token)* t;
        if (!consume(t, TT.question))
            return cond;
        auto a = expression();
        require(TT.colon);
        return astIf(getPos(t), cond, a, ternary());
    }

    // boolOp: [boolOp ("&&" | "||")] equals
    AstNode boolOp() {
        auto a = equals(&this,);
        const(Token)* t;
        for (;;) {
            if (consume(t, TT.and)) {
                a = astAnd(getPos(t), a, equals(&this,));
            }
            else if (consume(t, TT.or)) {
                a = astOr(getPos(t), a, equals(&this,));
            }
            else {
                return a;
            }
        }
    }

    // equals: [equals ("==" | "!=")] compare
    mixin(genLeftRecursive("equals", "compare", "==", "!="));

    // compare: bOr [("<"|">"|"<="|">=") bOr]
    mixin(genLeftRecursive("compare", "bOr", "<", ">", "<=", ">="));

    // bOr: [bOr ("|" | "^")] bAnd
    mixin(genLeftRecursive("bOr", "bAnd", "|", "^"));

    // bAnd: [bAnd "&"] bShift
    mixin(genLeftRecursive("bAnd", "bShift", "&"));

    // bShift: [bShift ("<<" | ">>")] add
    mixin(genLeftRecursive("bShift", "add", "<<", ">>"));

    // add: [add ("+" | "-" | "~")] multi
    mixin(genLeftRecursive("add", "multi", "+", "-", "~"));

    // multi: [multi ("*" | "/" | "//" | "%")] power
    mixin(genLeftRecursive("multi", "power", "*", "/", "//", "%"));

    // power: prefix ["**" power]
    static AstNode power(Parser* p) {
        auto a = p.prefix();
        const(Token)* t;
        if (!p.consume(t, TT.pow))
            return a;
        return p.binary(t, a, power(p));
    }

    // prefix: ["++" | "--" | "+" | "-" | "~" | "!"] postfix
    AstNode prefix() {
        const(Token)* t;
        if (consume(t, TT.inc, TT.dec)) {
            auto a = postfix();
            return astAssign(pos, a, unary(t, a));
        }
        if (consume(t, TT.plus, TT.minus, TT.not, TT.tilde)) {
            return unary(t, postfix());
        }
        return postfix();
    }
    // postfix: lambda {("++" | "--") | member | subscript | funcCall}
    // member: "." Identifier
    // method: "." Identifier funcCall
    // subscript: "[" expression "]"
    // funcCall: "(" (")" | expression {"," expression} ")")
    AstNode postfix() {
        auto a = lambda();
        for (;;) {
            const(Token)* t;
            if (consume(t, TT.inc, TT.dec)) {
                //reverseComma(a, a=opX(a));
                a = astReverseComma(getPos(t), a, astAssign(pos, a, unary(t, a)));
            }
            else if (consume(t, TT.dot)) {
                const(Token)* id;
                require(id, TT.identifier);
                if (consume(TT.lParen)) {
                    expressionSeq(TT.rParen,
                            (AstNode[] args) => a = astMethodCall(getPos(id), id.tsstr, a, args));
                }
                else {
                    a = astMember(getPos(id), a, id.tsstr);
                }
            }
            else if (consume(t, TT.lSquare)) {
                a = astSubscript(a.pos, a, expressionNoComma());
                require(TT.rSquare);
            }
            else if (consume(TT.lParen)) {
                expressionSeq(TT.rParen, (AstNode[] args) => a = astFuncCall(a.pos, a, args));
            }
            else {
                break;
            }
        }
        return a;
    }
    // lambda: "λ" { Identifier } | Identifier "->" expression
    //       | term | fun
    AstNode lambda() {
        const(Token)* t;
        if (!consume(t, TT.lambda)) {
            AstNode res;
            if (fun(res))
                return res;
            return term();
        }
        tsstring[] params;
        const(Token)* id;
        while (!is_(TT.arrow, TT.eof)) {
            require(id, TT.identifier);
            params ~= id.tsstr;
        }
        require(TT.arrow);
        return astLambda(getPos(t), params, expression());
    }
    // pair: expression ":" expression
    // term: "(" expression ")"
    //     | "[" ("]" | expression {"," expression} "]"
    //     | "{" ("}" | pair {"," pair} "}"
    //     | Number | Tsstring | Identifier | "nil" | "true" | "false"
    AstNode term() {
        const(Token)* t;
        if (consume(t, TT.lParen)) {
            auto e = expression();
            require(TT.rParen);
            return e;
        }
        if (consume(t, TT.lSquare)) {
            return expressionSeq(TT.rSquare, (AstNode[] args) => astList(getPos(t), args));
        }
        if (consume(t, TT.lCurly)) {
            enum terminator = TT.rCurly;
            AstNode[] args;
            while (!is_(TT.eof, terminator)) {
                args ~= expressionNoComma();
                require(TT.colon);
                args ~= expressionNoComma();
                if (!consume(TT.comma))
                    break;
            }
            require(terminator);
            return astDict(getPos(t), args);
        }
        if (consume(t, TT.number)) {
            return parseNumber(getPos(t), t.tsstr);
        }
        if (consume(t, TT.string)) {
            return parseString(getPos(t), t.tsstr);
        }
        if (consume(t, TT.identifier)) {
            return astVariable(getPos(t), t.tsstr);
        }
        if (consume(t, TT.false_)) {
            return astBool(getPos(t), false);
        }
        if (consume(t, TT.true_)) {
            return astBool(getPos(t), true);
        }
        if (consume(t, TT.nil)) {
            return astBool(getPos(t), true);
        }

        throw expected("term");
    }

    static AstNode parseNumber(Pos pos, tsstring str) {
        tsint invalid(tsstring t) {
            throw new ParserException(pos, format!"Invalid %s number '%s'"(t, str));
        }

        tsstring bkp = str;
        tsstring s;
        AstNode.Int i;
        AstNode.Float f;
        if (str.length >= 2 && str[0] == '0') {
            if (str[1] == 'x')
                return astInt(pos, parseHex(str[2 .. $], () => invalid("hex")));
            else if (str[1] == 'b')
                return astInt(pos, parseBinary(str[2 .. $], () => invalid("binary")));
            else if (str[1] == 'o')
                return astInt(pos, parseOctal(str[2 .. $], () => invalid("octal")));
        }
        if (str.formattedRead!"%d%s"(i, s) != 0 && s.length == 0) {
            return astInt(pos, i);
        }
        str = bkp;
        if (str.formattedRead!"%f%s"(f, s) != 0) { //&& s.length == 0) {
            return astFloat(pos, f);
        }
        throw new ParserException(pos, format!"Invalid number '%s'"(bkp));
    }

    static AstNode parseString(Pos pos, tsstring str) {
        import stdd.utf;
        import stdd.conv : to;

        bool isHex(tschar c) {
            return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
        }

        bool isOctal(tschar c) {
            return c >= '0' && c <= '7';
        }

        tschar get(const tschar* p, const tschar* end) {
            return p == end ? '\0' : *p;
        }

        tsstring res;
        auto p = str.ptr;
        const end = p + str.length;
        for (; p != end; ++p) {
            if (*p != '#') {
                res ~= *p;
            }
            else {
                //dfmt off
                switch (get(++p, end)) {
                case '#': res ~= '#'; break;
                case '\'': res ~= '\''; break;
                case '"': res ~= '"'; break;
                case 'a': res ~= '\a'; break;
                case 'b': res ~= '\b'; break;
                case 'f': res ~= '\f'; break;
                case 'e': res ~= '\033'; break;
                case 'n': res ~= '\n'; break;
                case 'r': res ~= '\r'; break;
                case 't': res ~= '\t'; break;
                case 'v': res ~= '\v'; break;
                case 'u': {
                    uint r = 0;
                    for (int i = 0; i < 4; ++i) {
                        tschar c = get(++p, end);
                        if (c >= '0' && c <= '9')
                            r = r << 4 | (c - '0');
                        else if (c >= 'a' && c <= 'f')
                            r = r << 4 | (c - 'a' + 10);
                         else if (c >= 'A' && c <= 'F')
                            r = r << 4 | (c - 'A' + 10);
                        else
                            throw new ParserException(pos, "Invalid unicode escape sequence");
                    }
                    res ~= (""w ~ cast(wchar)r).to!tsstring;
                } break;
                case 'U': {
                    uint r = 0;
                    for (int i = 0; i < 8; ++i) {
                        tschar c = get(++p, end);
                        if (c >= '0' && c <= '9')
                            r = r << 4 | (c - '0');
                        else if (c >= 'a' && c <= 'f')
                            r = r << 4 | (c - 'a' + 10);
                        else if (c >= 'A' && c <= 'F')
                            r = r << 4 | (c - 'A' + 10);
                        else
                            throw new ParserException(pos, "Invalid unicode escape sequence");
                    }
                    res ~= (""d ~ cast(dchar)r).to!tsstring;
                } break;
                default: {
                    uint r = 0;
                    --p;
                    for (int i = 0; i < 3; ++i) {
                        tschar c = get(++p, end);
                        if (c >= '0' && c <= '7')
                            r = r << 3 | (c - '0');
                        else
                            throw new ParserException(
                                pos, format!"Invalid octal escape sequence (char %d, '%c')"(c, c));
                    }
                    res ~= cast(tschar)r;
                } break;
                }
                //dfmt on
            }
        }
        return astString(pos, res);
    }
}

unittest {
    import token;
    import ast_node;
    import std.variant;

    import std.stdio;

    Parser p;
    alias T = Token;
    assert(p.parse([T("id", "print"), T("("), T("str", "hello"), T(")"), T(";")]));
    writefln(p.nodes[0].toString);
    assert(p.nodes[0].toString == `print("hello", )`);

    auto s = Parser.parseTsstring(-1, "hi #n #101 #u03BB #U0000e0b0")
        .val.peek!(AstNode.Tsstring).val;
    assert(s == "hi \n A \u03BB \U0000e0b0");

}
