module mos.ast.parser;

import stdd.format;
import mos.ast.ast_node;
import mos.ast.token;
import mos.misc;
import com.log;

class ParserException : MOSException {
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        super(pos, msg, file, line);
        //moslog!"ln %s @%d: %s"(line, pos, msg);
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
        return type() == TT.Eof;
    }

    TT type() {
        if (ptr < end) {
            //if (ptr.type != TT.newLine)
            return ptr.type;
        }
        return TT.Eof;
    }
    TT typePlus(int i) {
        if (ptr + i < end) {
            //if (ptr.type != TT.newLine)
            return (ptr+i).type;
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
    bool isPlus(A...)(int i, A args) {
        static if (args.length == 1) {
            return typePlus(i) == args[0];
        }
        else {
            auto t = typePlus(i);
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
    bool consume(A...)(out Pos p, A args) {
        if (is_(args)) {
            p = getPos(ptr++);
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
    void require(out Pos p, TT tt, string file = __FILE__, size_t line = __LINE__) {
        if (!consume(p, tt))
            throw expected(tt, file, line);
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
        case TT.Tilde: 
        case TT.CatEq: return astCat(pos, a, b);
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


    auto expressionSeq(bool useThis, F)(TT terminator, F fun) {
        return expressionSeq!useThis(terminator, TT.Comma, fun);
    }
    //
    auto expressionSeq(bool useThis, F)(TT terminator, TT separator, F fun) {
        AstNode[] args = [];
        while (!is_(TT.Eof, terminator)) {
            args ~= expression!useThis();
            if (!consume(separator))
                break;
        }

        require(terminator);
        return fun(args);
    }
    AstNode leftRecursive(bool useThis, alias Next, A...)(A args) {
        auto a = Next!useThis(&this);
        const(Token)* t;
        for (;;) {
            if (consume(t, args)) {
                a = binary(t, a, Next!useThis(&this));
            }
            else {
                return a;
            }
        }
    }
    static string genLeftRecursive(A...)(string name, string next, A args) {
        auto res = format!`
                    static AstNode %s(bool useThis)(Parser* p) {
                        return p.leftRecursive!(useThis, %s)(`(name, next);
        static foreach (a; args)
            res ~= format!"TT.%s, "(symbolicToTTName(a));
        res ~= "); }";
        return res;
    }
    // main: { "\n" | stmt }
    void main() {
        while (!isEof()) {
            if (!consume(TT.NewLine)) {
                tryStatement!false(nodes);
            }
        }
    }
    // statement: stmt | import
    void tryStatement(bool useThis)(ref AstNode[] nodes) {
        try {
            if (import_(nodes)) return;
            nodes ~= stmt!useThis();
            /*while(!contStackIsEmpty) {
                if (consume(TT.NewLine)) continue;
                if (contStackPeek())
                    require(TT.Dedent);
                contStackPop();
            }*/
        }
        catch (ParserException e) {
            errors ~= Error(e.pos, e.msg);
            ++ptr;
        }
    }


    // body_: statement | NewLine Indent { stmt } Dedent
    AstNode body_(bool useThis)() {
        Pos p;
        if (!consume(p, TT.NewLine))
            return stmt!useThis();
        require(TT.Indent);
        AstNode[] nodes;
        while (!consume(TT.Dedent)) {
            if (consume(TT.NewLine)) continue;
            tryStatement!useThis(nodes);
        }
        return astBody(p, nodes);
    }

    // statement: funcDef | prop | return_ | if_ | while_
    //          | for_ | ctrlFlow | struct_ | module_
    //          | expression '\n'
    AstNode stmt(bool useThis)() {
        AstNode n;
        //dfmt off
        if (funcDef!useThis(n)) return n;
        if (prop!useThis(n)) return n;
        if (return_!useThis(n)) return n;
        if (if_!useThis(n)) return n;
        if (while_!useThis(n)) return n;
        if (for_!useThis(n)) return n;
        if (ctrlFlow(n)) return n;
        if (struct_(n)) return n;
        if (module_(n)) return n;
        //dfmt on
        n = expression!useThis();
        require(TT.NewLine);
        /*
        if (consume(TT.dedent)) {
            popLevelStack();
            }*/
        return n;
    }

    // return_: "return" expression
    bool return_(bool useThis)(out AstNode res) {
        Pos p;
        if (!consume(p, TT.Return))
            return false;
        res = astReturn(p, expression!useThis());
        return true;
    }
    // import_: "import" Identifier { "." Identifier } ":" Identifier { "," Identifier }
    bool import_(ref AstNode[] nodes) {
        Pos p;
        if (!consume(p, TT.Import))
            return false;
        const(Token)* m;
        require(m, TT.Identifier);
        AstNode module_ = astVariable(getPos(m), m.mosstr);
        const(Token)* i;
        while (consume(TT.Dot)) {
            require(m, TT.Identifier);
            module_ = astMember(getPos(m), module_, m.mosstr);
        }
        require(TT.Colon);
        void afterColon() {
            require(m, TT.Identifier);
            auto pos = getPos(m);
            auto str = m.mosstr;
            mosstring x = "x";
            //prop str(): module_.str
            //prop str=(x): module_.str = x
            nodes ~= astAssign(p, astVariable(pos, str),
                               astProperty(pos,
                                    astLambda(pos, null, astMember(pos, module_, str)),
                                    astLambda(pos, [x], astAssign(pos, astVariable(pos, x), astMember(pos, module_, str)))
                                   ));
        }
        afterColon();
        while (consume(TT.Comma)) {
            afterColon();
        }
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

    // params: Identifier [ "," [funParams]] terminator
    void params(TT terminator, ref mosstring[] args) {
        const(Token)* p;
        while (!is_(TT.Eof, terminator)) {
            require(p, TT.Identifier);
            args ~= p.mosstr;
            if (!consume(TT.Comma))
                break;
        }
        require(terminator);
    }
    // params: Identifier [ "," [funParams]] [terminator2] terminator
    bool params2(TT terminator, TT terminator2, ref mosstring[] args) {
        const(Token)* p;
        bool res = false;
        while (!is_(TT.Eof, terminator)) {
            require(p, TT.Identifier);
            args ~= p.mosstr;
            if (!consume(TT.Comma)) {
                res = consume(terminator2);
                moslog!"fparams %s"(res);
                break;
            }
        }
        require(terminator);
        return res;
    }

    // captures: [ "[" params "]" ]
    mosstring[] captures() {
        mosstring[] res;
        if (consume(TT.LSquare)) {
            params(TT.RSquare, res);
        }
        return res;
    }

    // funcImpl: captures "(" params ["..."] ")" ":" body_
    AstNode.Lambda funcImpl(bool useThis)(Pos p) {
        mosstring[] caps = captures();

        require(TT.LParen);
        mosstring[] params;
        bool isVariadic = params2(TT.RParen, TT.Variadic, params);

        if (isVariadic && params.length == 0) {
            throw new ParserException(p, format!"Cant have variadic function with 0 parameters");
        }
        require(TT.Colon);
        return AstNode.Lambda(caps, params, body_!useThis(), isVariadic);
    }
    // propImpl: captures [ "(" ")" ] ":" body
    //         | "=" captures "(" Identifier ")" ":" body
    AstNode.Lambda propImpl(bool useThis)(out FuncType ft) {
        ft = consume(TT.Assign) ? FuncType.Setter : FuncType.Getter;
        mosstring[] caps = captures();
        mosstring[] params;
        const(Token)* p;
        if (ft == FuncType.Getter) {
            if (consume(TT.LParen)) {
                require(TT.RParen);
            }
        }
        else {
            require(TT.LParen);
            require(p, TT.Identifier);
            params ~= p.mosstr;
            require(TT.RParen);
        }

        require(TT.Colon);
        return AstNode.Lambda(caps, params, body_!useThis());
    }

    // prop: "prop" Identifier propImpl
    bool prop(bool useThis)(out AstNode res) {
        Pos p;
        if (!consume(p, TT.Prop))
            return false;
        const(Token)* t;

        require(t, TT.Identifier);
        auto p1 = getPos(t);
        auto name = t.mosstr;
        FuncType ft;
        auto val = propImpl!useThis(ft);
        res = ft == FuncType.Getter ?
            astGetterDef(p1, name, new AstNode(p, val)) :
            astSetterDef(p1, name, new AstNode(p, val));
        return true;
    }

    // funcDef: "fun" Identifier funcImpl
    bool funcDef(bool useThis)(out AstNode res) {
        Pos p;
        if (!consume(p, TT.Fun))
            return false;
        const(Token)* t;
        require(t, TT.Identifier);
        auto p1 = getPos(t);
        res = astAssign(p1, astVariable(p1, t.mosstr), new AstNode(p, funcImpl!useThis(p)));
        return true;
    }
    // if_: "if" expression ":" body_ {"\n"} {"elif" expression ":" body_ {"\n"} } [ "else" ":" body_ ]
    bool if_(bool useThis)(out AstNode res) {
        Pos p;
        if (!consume(p, TT.If))
            return false;
        auto cond = expression!useThis();
        require(TT.Colon);
        auto b = body_!useThis();
        //AstNode* lastElse = &stmt.else_;
        res = astIf(p, cond, b, null);
        auto last = res;

        while (consume(TT.NewLine)) continue;
        while (consume(p, TT.Elif)) {
            cond = expression!useThis();
            require(TT.Colon);
            b = body_!useThis();
            auto curr = astIf(p, cond, b, null);
            last.peek!(AstNode.If).else_ = curr;
            last = curr;
            while (consume(TT.NewLine)) continue;
        }

        if (consume(TT.Else)) {
            require(TT.Colon);
            last.peek!(AstNode.If).else_ = body_!useThis();
        }
        return true;
    }
    // while_: "while" expression ":" body_
    bool while_(bool useThis)(out AstNode res) {
        Pos p;
        if (!consume(p, TT.While))
            return false;
        auto cond = expression!useThis();
        require(TT.Colon);
        auto b = body_!useThis();
        res = astWhile(p, cond, b);
        return true;
    }
    // for_: "for" identifier ["," identifier] "in" expression ":" body_
    bool for_(bool useThis)(out AstNode res) {
        Pos p;
        if (!consume(p, TT.For))
            return false;
        const(Token)* a;
        const(Token)* b = null;
        require(a, TT.Identifier);
        if (consume(TT.Comma)) {
            require(b, TT.Identifier);
        }
        require(TT.In);

        auto col = expression!useThis();
        require(TT.Colon);
        auto body_ = body_!useThis();
        mosstring index, val;
        if (b is null) {
            index = "_";
            val = a.mosstr;
        }
        else {
            index = a.mosstr;
            val = b.mosstr;
        }
        res = astFor(p, index, val, col, body_);
        return true;
    }
    private abstract class Helper{
    static:
        void assign(Pos p, ref AstNode[mosstring] nodes, mosstring name, AstNode val) {
            if (name in nodes)
                throw new ParserException(p, format!"member '%s' already defined"(name));
            nodes[name] = val;
        }
        void assignProp(Pos p, FuncType ft, ref AstNode[mosstring] nodes, mosstring name, AstNode val) {
            if (auto ptr = name in nodes) {
                if (auto prop = ptr.val.peek!(AstNode.Property)) {
                    if (ft == FuncType.Getter) {
                        if (prop.get !is null)
                            throw new ParserException(p, format!"member '%s' already has a getter"(name));
                        prop.get = val;
                    } else {
                        if (prop.set !is null)
                            throw new ParserException(p, format!"member '%s' already has a setter"(name));
                        prop.set = val;
                    }
                }
                else throw new ParserException(p, format!"member '%s' already defined"(name));
            } else {
                if (ft == FuncType.Getter) {
                    nodes[name] = astProperty(p, val, null);
                } else {
                    nodes[name] = astProperty(p, null, val);
                }
            }
        }
    }

    bool module_(out AstNode res) {
        return moduleOrStruct!false(res) !is null;
    }


    bool struct_(out AstNode res) {
        return moduleOrStruct!true(res) !is null;
    }
    // struct_: "struct" Identifier ":" "\n" Indent {{"\n"} structData} Dedent
    // module_: "module" Indentifier ":" "\n" Indent { {"\n"} moduleData} Dedent
    // *Returns name or null
    mosstring moduleOrStruct(bool isStruct)(out AstNode res) {
        const(Token)* t;
        enum tt = isStruct ? TT.Struct : TT.Module;
        if (!consume(tt)) return null;
        require(t, TT.Identifier);
        auto name = t.mosstr;
        require(TT.Colon);
        require(TT.NewLine);
        require(TT.Indent);
        static if (isStruct)
            AstNode.Struct val;
        else AstNode.Module val;
        val.name = name;
        // thisOrName: [["this"] "."]
        // *returns: isStatic
        // nameOrDot: ["."]
        // *returns: true
        bool prefix() {
            const(Token)* n;
            if (consume(TT.Dot)) return true;
            static if (isStruct) {
                if (consume(TT.This)) {
                    require(TT.Dot);
                    return false;
                }
                return false;
            } else {
                return true;
            }
        }
        void assign(Pos p, bool isStatic, mosstring name, AstNode val_) {
            static if (isStruct) {
                if (isStatic)
                    Helper.assign(p, val.statics, name, val_);
                else Helper.assign(p, val.instance, name, val_);
            } else {
                Helper.assign(p, val.members, name, val_);
            }
        }
        void assignProp(Pos p, FuncType ft, bool isStatic, mosstring name, AstNode val_) {
            static if (isStruct) {
                if (isStatic)
                    Helper.assignProp(p, ft, val.statics, name, val_);
                else Helper.assignProp(p, ft, val.instance, name, val_);
            } else {
                Helper.assignProp(p, ft, val.members, name, val_);
            }
        }
        // memberAssign: prefix Identifier "=" ternary
        bool memberAssign() {
            const(Token)* n;
            bool isStatic = prefix();
            if (!consume(n, TT.Identifier)) return false;
            require(TT.Assign);
            auto val = ternary!false();
            assign(getPos(n), isStatic, n.mosstr, val);
            return true;
        }
        static if (isStruct) {
            // ctor: "this" funcImpl
            bool ctor() {
                Pos p;
                if (!is_(p, TT.This) || !isPlus(1, TT.LParen)) return false;
                ++ptr;//require would be pointless since we already know from the is_ above
                if (val.ctor !is null)
                    throw new ParserException(p, "constructor already defined");
                val.ctor = new AstNode(p, funcImpl!true(p));
                return true;
            }
        }
        // funDef: "fun" prefix Identifier funcImpl
        bool funDef() {
            Pos p;
            const(Token)* n;
            if (!consume(p, TT.Fun)) return false;
            auto isStatic = prefix();
            require(n, TT.Identifier);
            auto val = new AstNode(p, funcImpl!true(p));
            assign(getPos(n), isStatic, n.mosstr, val);
            return true;
        }
        // propDef: "prop" prefix Identifier propImpl
        bool propDef() {
            Pos p;
            const(Token)* n;
            FuncType ft;
            if (!consume(p, TT.Prop)) return false;
            auto isStatic = prefix();
            require(n, TT.Identifier);
            auto val = new AstNode(p, propImpl!true(ft));
            assignProp(getPos(n), ft, isStatic, n.mosstr, val);
            return true;
        }
        // subtype: module | struct
        bool subtype() {
            AstNode val_;
            auto name = moduleOrStruct!true(val_);
            if (name is null) {
                name = moduleOrStruct!false(val_);
                if (name is null)
                    return false;
            }
            static if (isStruct) {
                Helper.assign(val_.pos, val.statics, name, val_);
            } else {
                Helper.assign(val_.pos, val.members, name, val_);
            }
            return true;
        }

        // structData: ctor | funDef | propDef | memberAssign | subtype
        // moduleData: funDef | propDef | memberAssign | subtype
        bool content() {
            static if (isStruct) {
                return ctor() || funDef() || propDef() || memberAssign() || subtype();
            } else {
                return funDef() || propDef() || memberAssign() || subtype();
            }
        }
        /*if (!structData())
          throw new ParserException(getPos(t), "please use 'pass' for an empty struct definition");*/
        while (true) {
            while (consume(TT.NewLine)) continue;
            if (!content()) break;
        }
        require(TT.Dedent);
        res = new AstNode(getPos(t), val);
        return name;
    }


    // expression: assign
    AstNode expression(bool useThis)() {
        return assign!useThis();
    }

    // assign:  ternary | identifier assignOp assign
    // assignOp: "=" | "+=" | "-=" | "/=" | "//=" | "*=" | "%=" |
    //           "**=" | "<<=" | ">>=" | "&=" | "^=" | "|=" | "~="
    AstNode assign(bool useThis)() {
        auto a = ternary!useThis();
        const(Token)* sgn;
        if (consume(sgn, TT.Assign)) {
            a = astAssign(getPos(sgn), a, assign!useThis());
        }
        else if (consume(sgn, TT.PlusEq, TT.MinusEq, TT.DivEq, TT.IntDivEq,
                TT.MplyEq, TT.ModEq, TT.PowEq, TT.LshEq, TT.RshEq, TT.AndEq,
                TT.OrEq, TT.XorEq, TT.CatEq)) {
            a = astAssign(getPos(sgn), a, binary(sgn, a, assign!useThis()));
        }
        return a;
    }
    // ternary: boolOp [ "?" expression ":" ternary ]
    AstNode ternary(bool useThis)() {
        auto cond = boolOp!useThis();
        Pos p;
        if (!consume(p, TT.Question))
            return cond;
        AstNode a = expression!useThis();
        require(TT.Colon);

        return astIf(p, cond, a, ternary!useThis());
    }

    // boolOp: [boolOp ("&&" | "||")] equals
    AstNode boolOp(bool useThis)() {
        auto a = equals!useThis(&this);
        Pos p;
        for (;;) {
            if (consume(p, TT.And)) {
                a = astAnd(p, a, equals!useThis(&this));
            }
            else if (consume(p, TT.Or)) {
                a = astOr(p, a, equals!useThis(&this));
            }
            else {
                return a;
            }
        }
    }

    // equals: [equals ("==" | "!=")] compare
    mixin(genLeftRecursive("equals", "compare", "==", "!="));

    // compare: [bOr ("<"|">"|"<="|">=")] bOr
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
    static AstNode power(bool useThis)(Parser* p) {
        auto a = p.prefix!useThis();
        const(Token)* t;
        if (!p.consume(t, TT.Pow))
            return a;

        return p.binary(t, a, power!useThis(p));
    }

    // prefix: ["++" | "--" | "+" | "-" | "~" | "!"] postfix
    AstNode prefix(bool useThis)() {
        Pos p;
        const(Token)* t;
        if (consume(t, TT.Inc, TT.Dec)) {
            auto a = postfix!useThis();
            return astAssign(pos, a, unary(t, a));
        }
        if (consume(t, TT.Plus, TT.Minus, TT.Not, TT.Tilde)) {
            return unary(t, postfix!useThis());
        }
        return postfix!useThis();
    }
    // postfix: lambda {("++" | "--") | member | subscript | funcCall}
    // member: "." Identifier
    // method: "." Identifier funcCall
    // subscript: "[" expression "]"
    // funcCall: "(" (")" | expression {"," expression} ")")
    AstNode postfix(bool useThis)() {
        auto a = lambda!useThis();
        for (;;) {
            const(Token)* t;
            if (consume(t, TT.Inc, TT.Dec)) {
                //reverseComma(a, a=opX(a));
                a = astReverseComma(getPos(t), a, astAssign(pos, a, unary(t, a)));
            }
            else if (consume(t, TT.Dot)) {
                const(Token)* id;
                require(id, TT.Identifier);
                if (consume(TT.LParen)) {
                    auto p = getPos(id);
                    expressionSeq!useThis(TT.RParen,
                                  (AstNode[] args) => a = astFuncCall(p, astMember(p, a, id.mosstr),  args));
                }
                else {
                    a = astMember(getPos(id), a, id.mosstr);
                }
            }
            else if (consume(t, TT.LSquare)) {
                a = astSubscript(a.pos, a, expression!useThis());
                require(TT.RSquare);
            }
            else if (consume(TT.LParen)) {
                expressionSeq!useThis(TT.RParen, (AstNode[] args) => a = astFuncCall(a.pos, a, args));
            }
            else {
                break;
            }
        }
        return a;
    }
    // lambda: "λ" { Identifier } ["..."] "->" expression
    //       | term
    AstNode lambda(bool useThis)() {
        const(Token)* t;
        if (!consume(t, TT.Lambda)) {
            AstNode res;
            return term!useThis();
        }
        auto p = getPos(t);
        mosstring[] params;
        const(Token)* id;
        while (!is_(TT.Arrow, TT.Eof)) {
            require(id, TT.Identifier);
            params ~= id.mosstr;
        }
        bool isVariadic = consume(TT.Variadic);
        if (isVariadic && params.length == 0) {
            throw new ParserException(p, format!"Cant have variadic lambda with 0 parameters");
        }

        require(TT.Arrow);

        return astLambda(p, params, expression!useThis(), isVariadic);
    }
    // pair: expression ":" expressionNoComma
    // term: "(" expression {"," expression} ")"
    //     | "[" ("]" | expression {"," expression} "]"
    //     | "{" ("}" | pair {"," pair} "}"
    //     | Number | Mosstring | Identifier | "nil" | "true" | "false" | "this"
    AstNode term(bool useThis)() {
        Pos p;
        if (consume(p, TT.LParen)) {
            AstNode e = expression!useThis();

            if (consume(TT.Comma)) {
                return expressionSeq!useThis(TT.RParen, (AstNode[] args) => astTuple(p, e ~ args));
            }
            require(TT.RParen);
            return e;
        }
        if (consume(p, TT.LSquare)) {
            return expressionSeq!useThis(TT.RSquare, (AstNode[] args) => astList(p, args));
        }
        if (consume(p, TT.LCurly)) {
            enum terminator = TT.RCurly;
            AstNode[] args;
            while (!is_(TT.Eof, terminator)) {
                args ~= expression!useThis();
                require(TT.Colon);
                args ~= expression!useThis();
                if (!consume(TT.Comma))
                    break;
            }
            require(terminator);
            return astDict(p, args);
        }
        const(Token)* t;
        if (consume(t, TT.Number)) {
            return parseNumber(getPos(t), t.mosstr);
        }
        if (consume(t, TT.String)) {
            return parseString(getPos(t), t.mosstr);
        }
        if (consume(t, TT.Identifier)) {
            return astVariable(getPos(t), t.mosstr);
        }
        if (consume(p, TT.False)) {
            return astBool(p, false);
        }
        if (consume(p, TT.True)) {
            return astBool(p, true);
        }
        if (consume(p, TT.Nil)) {
            return astNil(p);
        }
        static if (useThis) {
            if (consume(p, TT.This)) {
                return astThis(p);
            }
        }
        throw expected("term");
    }

    static AstNode parseNumber(Pos pos, mosstring str) {
        mosint invalid(mosstring t) {
            throw new ParserException(pos, format!"Invalid %s number '%s'"(t, str));
        }

        mosstring bkp = str;
        mosstring s;
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

    static AstNode parseString(Pos pos, mosstring str) {
        import stdd.utf;
        import stdd.conv : to;

        bool isHex(moschar c) {
            return (c >= '0' && c <= '9') || (c >= 'a' && c <= 'f') || (c >= 'A' && c <= 'F');
        }

        bool isOctal(moschar c) {
            return c >= '0' && c <= '7';
        }

        moschar get(const moschar* p, const moschar* end) {
            return p == end ? '\0' : *p;
        }

        mosstring res;
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
                        moschar c = get(++p, end);
                        if (c >= '0' && c <= '9')
                            r = r << 4 | (c - '0');
                        else if (c >= 'a' && c <= 'f')
                            r = r << 4 | (c - 'a' + 10);
                         else if (c >= 'A' && c <= 'F')
                            r = r << 4 | (c - 'A' + 10);
                        else
                            throw new ParserException(pos, "Invalid unicode escape sequence");
                    }
                    res ~= (""w ~ cast(wchar)r).to!mosstring;
                } break;
                case 'U': {
                    uint r = 0;
                    for (int i = 0; i < 8; ++i) {
                        moschar c = get(++p, end);
                        if (c >= '0' && c <= '9')
                            r = r << 4 | (c - '0');
                        else if (c >= 'a' && c <= 'f')
                            r = r << 4 | (c - 'a' + 10);
                        else if (c >= 'A' && c <= 'F')
                            r = r << 4 | (c - 'A' + 10);
                        else
                            throw new ParserException(pos, "Invalid unicode escape sequence");
                    }
                    res ~= (""d ~ cast(dchar)r).to!mosstring;
                } break;
                default: {
                    uint r = 0;
                    --p;
                    for (int i = 0; i < 3; ++i) {
                        moschar c = get(++p, end);
                        if (c >= '0' && c <= '7')
                            r = r << 3 | (c - '0');
                        else
                            throw new ParserException(
                                pos, format!"Invalid octal escape sequence (char %d, '%c')"(c, c));
                    }
                    res ~= cast(moschar)r;
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
    import stdd.variant;

    import stdd.stdio;

    Parser p;
    alias T = Token;
    assert(p.parse([T("id", "print"), T("("), T("str", "hello"), T(")"), T(";")]));
    writefln(p.nodes[0].toString);
    assert(p.nodes[0].toString == `print("hello", )`);
    auto s = Parser.parseMosstring(-1, "hi #n #101 #u03BB #U0000e0b0")
        .val.peek!(AstNode.Mosstring).val;
    assert(s == "hi \n A \u03BB \U0000e0b0");

}
