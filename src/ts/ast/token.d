module ts.ast.token;

//pragma(cppmap, "<string>");
//pragma(cppmap, "<QString>");
//import (C++) QString;
//import (C++) std.string;

//import (C++) Qt.QtCore;
//import moc;
import std.format;
import qte5;

alias Pos = int;

alias TT = Token.Type;

extern(C++) void test(const ref Token t) {
    //int l;
    import core.stdc.stdio, std.stdio, std.array;
    printf("WOOOO\n");
    //auto s = t.val;
    printf("val: %s\n", t.valUtf8());
    //writeln(t.valUtf8());
    //printf("%s", s.String);
    //auto i = t.gimme10();
    //int l;
    //auto utf = t.valUtf16(l);
    //writeln("WOOOO");
    //wchar[] a = uninitializedArray!(wchar[])(l);
    //a[] = utf[0..l];
    //writeln(a);
    //printf("%s", t.toString());
    //printf("weep %d", i);
}
extern(C++):
struct Token {
    enum Type {
        eof,
        newLine,
        terminator,
        comma,
        true_,
        false_,
        nil,
        fun,
        if_,
        else_,
        break_,
        continue_,
        while_,
        for_,
        in_,
        return_,
        identifier,
        number,
        string,
        lambda,
        arrow,
        lParen,
        rParen,
        lSquare,
        rSquare,
        lCurly,
        rCurly,
        dot,
        inc,
        dec,
        plus,
        minus,
        mply,
        div,
        intDiv,
        mod,
        pow,
        eq,
        ne,
        lt,
        gt,
        le,
        ge,
        and_,
        or_,
        not_,
        xor_,
        bAnd,
        bOr,
        lsh,
        rsh,
        tilde,
        assign,
        question,
        colon,
        catEq,
        plusEq,
        minusEq,
        mplyEq,
        divEq,
        intDivEq,
        modEq,
        powEq,
        lshEq,
        rshEq,
        andEq,
        xorEq,
        orEq,
    }
    Type type;
    QString val;

    //this(Type type, QString str);
    QString toString() const;
    const(wchar)* valUtf16(ref int len) const;
    const(char)* valUtf8() const;
    int size() const;

}

/*
import std.format;
import std.string;
import std.conv;

alias Pos = int;
alias TT = Token.Type;
alias c_str = const(char)*;

private struct TypeData {
    string typeName;
    string symbolicStr;
    string functionName;
    c_str function(c_str v) editorRepr;
}
private TypeData td(string typeName,
                    string symbolicStr,
                    string functionName,
                    string function(string v) pure nothrow editorRepr)() {
    return TypeData(
        typeName, symbolicStr, functionName,
        (c_str v) => editorRepr(v.to!string).fromStringz());
}
// dfmt off
private enum typeDatas = [
    //      typeName,     symbolicStr, functionName,  editorRepr
    td!("eof",          "EOF",       "",         x=>"EOF"),//only used by parser
    td!("newLine",      "NL",        "",         x=>"\n"),
    td!("terminator",   ";",         "",         x=>";"),
    td!("comma",        ",",         "",         x=>", "),
    td!("true_",        "true",      "",         x=>"true"),
    td!("false_",       "false",     "",         x=>"false"),
    td!("nil",          "nil",       "",         x=>"nil"),
    td!("fun",          "fun",       "",         x=>"fun "),
    td!("if_",          "if",        "",         x=>"if "),
    td!("else_",        "else",      "",         x=>"else "),
    td!("break_",       "break",     "",         x=>"break "),
    td!("continue_",    "continue",  "",         x=>"continue "),
    td!("while_",       "while",     "",         x=>"while "),
    td!("for_",         "for",       "",         x=>"for "),
    td!("in_",          "in",        "",         x=>" in "),
    td!("return_",      "return ",   "",         x=>"return "),
    td!("identifier",   "id",        "",         x=>x),
    td!("number",       "num",       "",         x=>x),
    td!("string",       "str",       "",         x=>format!`"%s"`(x)),
    td!("lambda",       "λ",         "",         x=>"λ"),
    td!("arrow",        "->",        "",         x=>"->"),
    td!("lParen",       "(",         "",         x=>"("),
    td!("rParen",       ")",         "",         x=>")"),
    td!("lSquare",      "[",         "",         x=>"["),
    td!("rSquare",      "]",         "",         x=>"]"),
    td!("lCurly",       "{",         "",         x=>"{"),
    td!("rCurly",       "}",         "",         x=>"}"),
    td!("dot",          ".",         "",         x=>"."),
    td!("inc",          "++",        "opInc",    x=>"++"),
    td!("dec",          "--",        "opDec",    x=>"--"),
    td!("plus",         "+",         "opAdd",    x=>" + "),
    td!("minus",        "-",         "opSub",    x=>" - "),
    td!("mply",         "*",         "opMply",   x=>" * "),
    td!("div",          "/",         "opDiv",    x=>" / "),
    td!("intDiv",       "//",        "opIntdiv", x=>" // "),
    td!("mod",          "%",         "opMod",    x=>" % "),
    td!("pow",          "**",        "opPow",    x=>" ** "),
    td!("eq",           "==",        "opEq",     x=>" == "),
    td!("ne",           "!=",        "",         x=>" != "),
    td!("lt",           "<",         "",         x=>" < "),
    td!("gt",           ">",         "",         x=>" > "),
    td!("le",           "<=",        "",         x=>" <= "),
    td!("ge",           ">=",        "",         x=>" >= "),
    td!("and",          "&&",        "",         x=>" && "),
    td!("or",           "||",        "",         x=>" || "),
    td!("not",          "!",         "opNot",    x=>"!"),
    td!("xor",          "^",         "opXor",    x=>" ^ "),
    td!("bAnd",         "&",         "opAnd",    x=>" & "),
    td!("bOr",          "|",         "opOr",     x=>" | "),
    td!("lsh",          "<<",        "opLsh",    x=>" << "),
    td!("rsh",          ">>",        "opRsh",    x=>" >> "),
    td!("tilde",        "~",         "opCat",    x=>" ~ "),
    td!("assign",       "=",         "",         x=>" = " ),
    td!("question",     "?",         "",         x=>"?"),
    td!("colon",        ":",         "",         x=>":"),
    td!("catEq",        "~=",        "opCat",    x=>" ~= "),
    td!("plusEq",       "+=",        "opAdd",    x=>" += "),
    td!("minusEq",      "-=",        "opSub",    x=>" -= "),
    td!("mplyEq",       "*=",        "opMply",   x=>" *= "),
    td!("divEq",        "/=",        "opDiv",    x=>" /= "),
    td!("intDivEq",     "//=",       "opIntdiv", x=>" //= "),
    td!("modEq",        "%=",        "opMod",    x=>" %= "),
    td!("powEq",        "**=",       "opPow",    x=>" **= "),
    td!("lshEq",        "<<=",       "opLsh",    x=>" <<= "),
    td!("rshEq",        ">>=",       "opRsh",    x=>" >>= "),
    td!("andEq",        "&=",        "opAnd",    x=>" &= "),
    td!("xorEq",        "^=",        "opXor",    x=>" ^= "),
    td!("orEq",         "|=",        "opOr",     x=>" |= "),
];
// dfmt on
string binaryFunctionName(TT type) {
    final switch (type) {
        static foreach (a; typeDatas)
            mixin(format!`case TT.%s: return "%s";`(a.typeName, a.functionName));
    }
}

string unaryFunctionName(TT type) {
    switch (type) {
        // dfmt off
    case TT.plus: return "opPlus";
    case TT.minus: return "opMinus";
    case TT.inc: return "opInc";
    case TT.dec: return "opDec";
    case TT.not: return "opNot";
    case TT.tilde: return "opCom";
    default: assert(0);
        // dfmt on
    }
}
string symbolicStr(TT type) {
    final switch (type) {
        static foreach (a; typeDatas) {
            mixin(format!`case Token.Type.%s: return "%s";`(a.typeName, a.symbolicStr));
        }
    }
}
/*
string symbolicToTTName(string symbolic) {
    final switch (symbolic) {
        static foreach (a; typeDatas) {
            mixin(format!r"case `%s`: return `%s`;"(a.symbolicStr, a.typeName));
        }
    }
}
static Type symbolicToTT(string t) {
        switch (t) {
            static foreach (a; typeDatas)
                mixin(format!r"case `%s`: return Type.%s;"(a.symbolicStr, a.typeName));
        default:
            assert(0, format!"invalid type '%s'"(t));
        }
    }
* /


extern(C++, ts):
struct Token {
    private static string _genType() {
        auto result = "enum Type {";
        static foreach (a; typeDatas)
            result ~= a.typeName ~ ", ";
        return result ~ "}";
    }
    mixin(_genType());


    Type type;
    const(char)* val;
    this(Type type, const(char)* val = "") {
        this.type = type;
        this.val = val;
    }
    /*
    private this(string t, const(char*) val = "") {
        this.type = symbolicToType(t);
        this.val = val;

    }* /
    const(char)* toString() {
        switch (type) {
            static foreach (a; typeDatas) {
                mixin(format!`case Type.%s:`(a.typeName));
                return a.editorRepr(val);
            }
            default:
            assert(0);
        }

    }
    //imm string val;
    /*

    this(Type type, immutable(char)[] val="") {
        this.type = type;
        this.val = val;
    }
    private this(string t, string val="") {
        this.type = symbolicToType(t);
        this.val = val;
    }
    immutable(char)[] c_str() {
        return val;
    }
    string toString() {
        switch (type) {
            static foreach (a; typeDatas) {
                mixin(format!`case Type.%s:`(a.typeName));
                return a.editorRepr(val);
            }
            default:
            assert(0);
        }
    }


    static Type symbolicToType(string t) {
        switch (t) {
            static foreach (a; typeDatas)
                mixin(format!r"case `%s`: return Type.%s;"(a.symbolicStr, a.typeName));
        default:
            assert(0, format!"invalid type '%s'"(t));
        }
    }
* /
}
/*
static foreach (a; typeDatas)
    mixin(format!`Token tok_%s(string s = ""){ return Token(Token.Type.%s, s); }`(
              ((s)=>s[$-1]=='_'? s[0..$-1] : s)(a.typeName), a.typeName));


unittest {
    assert(tok_string("hello").toString() == `"hello"`);
    assert(tok_rsh().type.binaryFunctionName == "opRsh");
    enum t = tok_plus();
    assert(t.type.unaryFunctionName == "opPlus");
    assert(t.type.binaryFunctionName == "opAdd");
    }*/
