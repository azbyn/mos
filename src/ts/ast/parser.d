module ts.ast.parser;

import stdd.format;
import ts.ast.ast_node;
import ts.ast.token;
import ts.misc;
import com.log;

class ParserException : TSException {
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        super(pos, msg, file, line);
        tslog!"ln %s @%d: %s"(line, pos, msg);
    }
}

struct Parser {

private:

    ParserException expected(TT tt, string file = __FILE__, size_t line = __LINE__) {
        return expected(tt.symbolicStr, file, line);
    }

    ParserException expected(string tt, string file = __FILE__, size_t line = __LINE__) {
        return new ParserException(pos, format!"Expected %s, found %s"(tt,
                                   type().symbolicStr), file, line);
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
    bool[] _contStack;
    void contStackPush(bool b) {
        _contStack ~= b;
        tslog!"{ %s"(b);
    }
    bool contStackPop() {
        import stdd.range.primitives;
        assert(!contStackIsEmpty);
        auto res = _contStack.back();
        tslog!"} %s"(res);
        _contStack.popBack();
        return res;
    }
    bool contStackPeek() {
        import stdd.range.primitives;
        return _contStack.back();
    }
    bool contStackIsEmpty() { return _contStack.length == 0; }

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
        _contStack = [];
        main();
        return errors.length == 0;
    }

    bool isEof() {
        return type() == TT.Eof;
    }

    TT type() {
        if (ptr < end) {
            //if (ptr.type != TT.newLine)
            return ptr.type;
        }
        return TT.Eof;
    }

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

    void require(TT tt, string file = __FILE__, size_t line = __LINE__) {
        if (!consume(tt))
            throw expected(tt, file, line);
    }

    void require(out const(Token)* t, TT tt, string file = __FILE__, size_t line = __LINE__) {
        if (!consume(t, tt))
            throw expected(tt, file, line);
    }
    tsstring requireIdentifier(string file = __FILE__, size_t line = __LINE__) {
        const(Token)* t;
        require(t, TT.Identifier);
        return t.tsstr;
    }

    AstNode binary(const(Token)* t, AstNode a, AstNode b) {
        return binary(getPos(t), t.type, a, b);
    }

    AstNode binary(Pos pos, TT type, AstNode a, AstNode b) {
        //dfmt off
        switch (type) {
        case TT.Lt:
        case TT.Gt:
        case TT.Le:
        case TT.Ge: return astCmp(pos, type, a, b);
        case TT.Ne: return unary(pos, TT.Not, binary(pos, TT.Eq, a, b));
        default: return astBinary(pos, type.binaryFunctionName, a, b);
        }
        //dfmt on
    }

    AstNode unary(const(Token)* t, AstNode a) {
        return unary(getPos(t), t.type, a);
    }

    AstNode unary(Pos p, TT type, AstNode a) {
        return astFuncCall(pos, astMember(pos, a, type.unaryFunctionName), null);
    }

    AstNode leftRecursive(A...)(AstNode function(Parser*) next, A args) {
        auto a = next(&this);
        const(Token)* t;
        for (;;) {
            if (consume(t, args)) {
                cont();
                a = binary(t, a, next(&this));
            }
            else {
                return a;
            }
        }
    }

    auto expressionSeq(F)(TT terminator, F fun) {
        return expressionSeq(terminator, TT.Comma, fun);
    }
    //
    auto expressionSeq(F)(TT terminator, TT separator, F fun) {
        AstNode[] args = [];
        while (!is_(TT.Eof, terminator)) {
            args ~= expression();
            if (!consume(separator))
                break;
            cont();
        }

        cont();
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
    // main: { "\n" | stmt }
    void main() {
        while (!isEof()) {
            if (!consume(TT.NewLine)) {
                tryStatement(nodes);
            }
        }
    }

    void tryStatement(ref AstNode[] nodes) {
        try {
            nodes ~= stmt();
            while(!contStackIsEmpty) {
                if (consume(TT.NewLine)) continue;
                if (contStackPeek())
                    require(TT.Dedent);
                contStackPop();
            }
        }
        catch (ParserException e) {
            errors ~= Error(e.pos, e.msg);
            ++ptr;
        }
    }


    //["\n" Indent] {"\n"}
    bool cont() {
        if (!consume(TT.NewLine)) return false;
        if (consume(TT.Indent)) {
            contStackPush(true);
        }
        else {
            contStackPush(false);
        }
        while(!isEof()) {
            if (!consume(TT.NewLine)) break;
        }
        return true;
    }
    // body_: statement | NewLine Indent { stmt } Dedent
    AstNode body_() {
        const(Token)* t;
        if (!consume(t, TT.NewLine))
            return stmt();
        require(TT.Indent);
        AstNode[] nodes;
        while (!consume(TT.Dedent)) {
            if (consume(TT.NewLine)) continue;
            tryStatement(nodes);
        }
        return astBody(getPos(t), nodes);
    }

    // statement: funcDef | prop | return_ | if_ | while_
    //          | for_ | ctrlFlow | struct_ | import_
    //          | expression '\n'
    AstNode stmt() {
        AstNode n;
        //dfmt off
        if (funcDef(n)) return n;
        if (prop(n)) return n;
        if (return_(n)) return n;
        if (if_(n)) return n;
        if (while_(n)) return n;
        if (for_(n)) return n;
        if (ctrlFlow(n)) return n;
        if (module_(n)) return n;
        if (import_(n)) return n;
        //dfmt on
        n = expression();
        require(TT.NewLine);
        /*
        if (consume(TT.dedent)) {
            popLevelStack();
            }*/
        return n;
    }

    // return_: "return" expression
    bool return_(out AstNode res) {
        const(Token)* t;
        if (!consume(t, TT.Return))
            return false;
        res = astReturn(getPos(t), expression());
        return true;
    }
    // import_: "import" Identifier { "." Identifier } ":" Identifier { "," Identifier }
    bool import_(out AstNode res) {
        const(Token)* t;
        if (!consume(t, TT.Import))
            return false;
        tsstring[] module_;
        tsstring[] symbols;

        module_ ~= requireIdentifier();
        const(Token)* i;
        while (consume(TT.Dot)) {
            module_ ~= requireIdentifier();
        }
        require(TT.Colon);
        symbols ~= requireIdentifier();
        while (consume(TT.Comma)) {
            module_ ~= requireIdentifier();
        }
        res = astImport(getPos(t), module_, symbols);
        return true;
    }
    // ctrlFlow: "break" | "continue"
    bool ctrlFlow(out AstNode res) {
        const(Token)* t;
        if (!consume(t, TT.Break, TT.Continue))
            return false;
        res = astCtrlFlow(getPos(t), t.type);
        return true;
    }

    // funcParams: Identifier [ "," cont [funParams]] Terminator
    void funcParams(TT terminator, ref tsstring[] args) {
        const(Token)* p;
        while (!is_(TT.Eof, terminator)) {
            cont();
            require(p, TT.Identifier);
            args ~= p.tsstr;
            if (!consume(TT.Comma))
                break;
        }
        cont();
        require(terminator);
    }
    // captures: [ "[" cont funcParams cont "]" ]
    tsstring[] captures() {
        tsstring[] res;
        if (consume(TT.LSquare)) {
            funcParams(TT.RSquare, res);
        }
        return res;
    }

    // prop: propGet | propSet
    // propGet: "prop" Identifier captures "["(" cont [Identifier cont] ")"] ":" body_
    // propSet: "prop" Identifier "=" captures "(" cont Identifier cont ["," Identifier cont] ")" ":" body_
    bool prop(out AstNode res) {
        Pos p;
        Pos p2;
        tsstring name;
        FuncType ft;
        AstNode.Lambda val;
        if (!prop(p, p2, name, ft, val)) return false;
        res = ft == FuncType.Getter ?
            astGetterDef(p, name, new AstNode(p2, val)) :
            astSetterDef(p, name, new AstNode(p2, val));
        return true;
    }
    bool prop(out Pos pos, out Pos pos2, out tsstring name, out FuncType ft, out AstNode.Lambda res) {
        const(Token)* f;
        if (!consume(f, TT.Prop))
            return false;
        const(Token)* t;

        require(t, TT.Identifier);
        pos = getPos(t);
        pos2 =  getPos(f);
        name = t.tsstr;
        ft = consume(TT.Assign) ? FuncType.Setter : FuncType.Getter;

        tsstring[] caps = captures();
        cont();
        tsstring[] params;
        const(Token)* p;
        if (ft == FuncType.Getter) {
            if (consume(TT.LParen)){
                cont();
                if (consume(p, TT.Identifier)) {
                    params ~= p.tsstr;
                    cont();
                }
                require(TT.RParen);
            }
        } else {
            require(TT.LParen);
            cont();
            params ~= requireIdentifier();
            cont();
            if (consume(TT.Comma)) {
                params ~= requireIdentifier();
                cont();
            }

            require(TT.RParen);
        }

        require(TT.Colon);
        res = AstNode.Lambda(caps, params, body_);
        return true;
    }

    // funcDef: "fun" Identifier captures "(" funcParams ")" ":" body_
    bool funcDef(out AstNode res) {
        tsstring name;
        AstNode.Lambda val;
        Pos p, p2;
        if (!funcDef(p, p2, name, val))
            return false;
        res = astAssign(p, astVariable(p, name), new AstNode(p2, val));
        return true;
    }
    bool funcDef(out Pos p, out Pos p2, out tsstring name, out AstNode.Lambda res) {
        const(Token)* f;
        if (!consume(f, TT.Fun))
            return false;
        const(Token)* t;
        require(t, TT.Identifier);
        p = getPos(t);
        p2 = getPos(f);
        name = t.tsstr;
        tsstring[] caps = captures();
        cont();
        require(TT.LParen);
        tsstring[] params;
        funcParams(TT.RParen, params);
        require(TT.Colon);
        res = AstNode.Lambda(caps, params, body_());
        return true;
    }
    // if_: "if" expression ":" body_ {"\n"} {"elif" expression ":" body_ {"\n"} } [ "else" ":" body_ ]
    bool if_(out AstNode res) {
        const(Token)* t;
        if (!consume(t, TT.If))
            return false;
        auto cond = expression();
        require(TT.Colon);
        auto b = body_();
        //AstNode* lastElse = &stmt.else_;
        res = astIf(getPos(t), cond, b, null);
        auto last = res;

        while (consume(TT.NewLine)) continue;
        while (consume(t, TT.Elif)) {
            cond = expression();
            require(TT.Colon);
            b = body_();
            auto curr = astIf(getPos(t), cond, b, null);
            last.peek!(AstNode.If).else_ = curr;
            last = curr;
            while (consume(TT.NewLine)) continue;
        }

        if (consume(TT.Else)) {
            require(TT.Colon);
            last.peek!(AstNode.If).else_ = body_();
        }
        return true;
    }
    // while_: "while" expression ":" body_
    bool while_(out AstNode res) {
        const(Token)* t;
        if (!consume(t, TT.While))
            return false;
        auto cond = expression();
        require(TT.Colon);
        auto b = body_();
        res = astWhile(getPos(t), cond, b);
        return true;
    }
    // for_: "for" identifier ["," cont identifier] "in" cont expression ":" body_
    bool for_(out AstNode res) {
        const(Token)* t;
        if (!consume(t, TT.For))
            return false;
        const(Token)* a;
        const(Token)* b = null;
        require(a, TT.Identifier);
        if (consume(TT.Comma)) {
            cont();
            require(b, TT.Identifier);
        }
        require(TT.In);

        cont();
        auto col = expression();
        require(TT.Colon);
        auto body_ = body_();
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
    // module_: ("struct" | "module") Identifier captures ":" "\n" Indent { {"\n"} structData} Dedent
    // moduleData: funcDef | prop | memberAssign | module_
    // memberAssign: Identifier "=" cont ternary

    bool module_(out AstNode res) {
        tsstring _;
        return module_(res, _);
    }

    bool module_(out AstNode res, out tsstring name) {
        const(Token)* t;
        if (!consume(t, TT.Struct, TT.Module)) return false;
        AstNode[tsstring] members;
        AstNode.Lambda[tsstring] methods;
        AstNode.Lambda[tsstring] setters;
        AstNode.Lambda[tsstring] getters;
        bool memberAssign() {
            const(Token)* t;
            if (!consume(t, TT.Identifier))
                return false;
            require(TT.Assign);
            cont();
            members[t.tsstr] = ternary();
            return true;
        }

        bool submodule() {
            AstNode m;
            tsstring s;
            if (!module_(m, s)) return false;
            members[s] = m;
            return true;
        }
        bool memberFuncDef() {
            tsstring name;
            AstNode.Lambda val;
            Pos p, p2;
            if (!funcDef(p, p2, name, val))
                return false;
            methods[name] = val;
            return true;
        }
        bool memberProp() {
            Pos p, p2;
            tsstring name;
            FuncType ft;
            AstNode.Lambda val;
            //assignFuncType(ft, members, name,val);
            if (!prop(p, p2, name, ft, val))
                return false;
            if (ft == FuncType.Getter)
                getters[name] = val;
            else
                setters[name] = val;
            return true;
        }
        bool structData() {
            return memberFuncDef() || memberProp() || memberAssign() || submodule();
        }

        const(Token)* n;
        require(n, TT.Identifier);
        name = n.tsstr;
        tsstring[] caps = captures();

        require(TT.Colon);
        require(TT.NewLine);
        require(TT.Indent);

        /*if (!structData())
          throw new ParserException(getPos(t), "please use 'pass' for an empty struct definition");*/
        while (true) {
            while (consume(TT.NewLine)) continue;
            if (!structData()) break;
        }
        require(TT.Dedent);
        res = astModule(getPos(n), t.type == TT.Struct, name, caps, members, methods, getters, setters);
        return true;
    }

    // expression: assign
    AstNode expression() {
        return assign();
    }

    // assign:  ternary | identifier assignOp cont assign
    // assignOp: "=" | "+=" | "-=" | "/=" | "//=" | "*=" | "%=" |
    //           "**=" | "<<=" | ">>=" | "&=" | "^=" | "|=" | "~="
    AstNode assign() {
        auto a = ternary();
        const(Token)* sgn;
        if (consume(sgn, TT.Assign)) {
            cont();
            a = astAssign(getPos(sgn), a, assign());
        }
        else if (consume(sgn, TT.PlusEq, TT.MinusEq, TT.DivEq, TT.IntDivEq,
                TT.MplyEq, TT.ModEq, TT.PowEq, TT.LshEq, TT.RshEq, TT.AndEq,
                TT.OrEq, TT.XorEq, TT.CatEq)) {
            cont();
            a = astAssign(getPos(sgn), a, binary(sgn, a, assign()));
        }
        return a;
    }
    // ternary: boolOp [ "?" cont expression ":" cont ternary ]
    AstNode ternary() {
        auto cond = boolOp();
        const(Token)* t;
        if (!consume(t, TT.Question))
            return cond;
        AstNode a;
        {
            cont();
            a = expression();
        }
        require(TT.Colon);

        cont();
        return astIf(getPos(t), cond, a, ternary());
    }

    // boolOp: [boolOp ("&&" | "||") cont] equals
    AstNode boolOp() {
        auto a = equals(&this,);
        const(Token)* t;
        for (;;) {
            if (consume(t, TT.And)) {
                cont();
                a = astAnd(getPos(t), a, equals(&this,));
            }
            else if (consume(t, TT.Or)) {
                cont();
                a = astOr(getPos(t), a, equals(&this,));
            }
            else {
                return a;
            }
        }
    }

    // equals: [equals ("==" | "!=") cont] compare
    mixin(genLeftRecursive("equals", "compare", "==", "!="));

    // compare: [bOr ("<"|">"|"<="|">=") cont] bOr
    mixin(genLeftRecursive("compare", "bOr", "<", ">", "<=", ">="));

    // bOr: [bOr ("|" | "^") cont] bAnd
    mixin(genLeftRecursive("bOr", "bAnd", "|", "^"));

    // bAnd: [bAnd "&" cont] bShift
    mixin(genLeftRecursive("bAnd", "bShift", "&"));

    // bShift: [bShift ("<<" | ">>") cont] add
    mixin(genLeftRecursive("bShift", "add", "<<", ">>"));

    // add: [add ("+" | "-" | "~") cont] multi
    mixin(genLeftRecursive("add", "multi", "+", "-", "~"));

    // multi: [multi ("*" | "/" | "//" | "%") cont] power
    mixin(genLeftRecursive("multi", "power", "*", "/", "//", "%"));

    // power: prefix ["**" cont power]
    static AstNode power(Parser* p) {
        auto a = p.prefix();
        const(Token)* t;
        if (!p.consume(t, TT.Pow))
            return a;

        p.cont();
        //auto c = p.contstart();

        auto res = p.binary(t, a, power(p));
        //p.contend(c);
        return res;
    }

    // prefix: ["++" | "--" | "+" | "-" | "~" | "!"] postfix
    AstNode prefix() {
        const(Token)* t;
        if (consume(t, TT.Inc, TT.Dec)) {
            auto a = postfix();
            return astAssign(pos, a, unary(t, a));
        }
        if (consume(t, TT.Plus, TT.Minus, TT.Not, TT.Tilde)) {
            return unary(t, postfix());
        }
        return postfix();
    }
    // postfix: lambda {("++" | "--") | member | subscript | funcCall}
    // member: "." cont Identifier
    // method: "." cont Identifier funcCall
    // subscript: "[" cont expression "]"
    // funcCall: "(" cont (")" | expression {"," cont expression} cont ")")
    AstNode postfix() {
        auto a = lambda();
        for (;;) {
            const(Token)* t;
            if (consume(t, TT.Inc, TT.Dec)) {
                //reverseComma(a, a=opX(a));
                a = astReverseComma(getPos(t), a, astAssign(pos, a, unary(t, a)));
            }
            else if (consume(t, TT.Dot)) {
                cont();
                const(Token)* id;
                require(id, TT.Identifier);
                if (consume(TT.LParen)) {
                    auto p = getPos(id);
                    expressionSeq(TT.RParen,
                                  (AstNode[] args) => a = astFuncCall(p, astMember(p, a, id.tsstr),  args));
                }
                else {
                    a = astMember(getPos(id), a, id.tsstr);
                }
            }
            else if (consume(t, TT.LSquare)) {
                cont();
                a = astSubscript(a.pos, a, expression());
                require(TT.RSquare);
            }
            else if (consume(TT.LParen)) {
                cont();
                expressionSeq(TT.RParen, (AstNode[] args) => a = astFuncCall(a.pos, a, args));
            }
            else {
                break;
            }
        }
        return a;
    }
    // lambda: "λ" { Identifier cont } | Identifier "->" cont expression
    //       | term
    AstNode lambda() {
        const(Token)* t;
        if (!consume(t, TT.Lambda)) {
            AstNode res;
            return term();
        }
        tsstring[] params;
        const(Token)* id;
        while (!is_(TT.Arrow, TT.Eof)) {
            require(id, TT.Identifier);
            cont();
            params ~= id.tsstr;
        }
        require(TT.Arrow);
        cont();

        return astLambda(getPos(t), params, expression());
    }
    // pair: expression ":" cont expressionNoComma
    // term: "(" cont expression cont {"," cont expression} ")"
    //     | "[" cont ("]" | expression {"," cont expression} cont "]"
    //     | "{" cont ("}" | pair {"," cont pair} cont  "}"
    //     | Number | Tsstring | Identifier | "nil" | "true" | "false"
    AstNode term() {
        const(Token)* t;
        if (consume(t, TT.LParen)) {
            cont();
            AstNode e = expression();

            cont();
            if (consume(TT.Comma)) {
                cont();
                return expressionSeq(TT.RParen, (AstNode[] args) => astTuple(getPos(t), e ~ args));
            }
            require(TT.RParen);
            return e;
        }
        if (consume(t, TT.LSquare)) {
            cont();
            return expressionSeq(TT.RSquare, (AstNode[] args) => astList(getPos(t), args));
        }
        if (consume(t, TT.LCurly)) {
            cont();
            enum terminator = TT.RCurly;
            AstNode[] args;
            while (!is_(TT.Eof, terminator)) {
                args ~= expression();
                require(TT.Colon);
                cont();
                args ~= expression();
                if (!consume(TT.Comma))
                    break;
                cont();
            }
            require(terminator);
            return astDict(getPos(t), args);
        }
        if (consume(t, TT.Number)) {
            return parseNumber(getPos(t), t.tsstr);
        }
        if (consume(t, TT.String)) {
            return parseString(getPos(t), t.tsstr);
        }
        if (consume(t, TT.Identifier)) {
            return astVariable(getPos(t), t.tsstr);
        }
        if (consume(t, TT.False)) {
            return astBool(getPos(t), false);
        }
        if (consume(t, TT.True)) {
            return astBool(getPos(t), true);
        }
        if (consume(t, TT.Nil)) {
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
