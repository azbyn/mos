module ts.ast.token;

public import ts.types;

import stdd.format;


private struct TypeData {
    string typeName;
    string symbolicStr;
    tsstring functionName;
}

//dfmt off
private enum typeDatas = [
    //      typeName,     symbolicStr, functionName
    TypeData("eof",          "EOF",       ""         ),//only used by parser
    TypeData("newLine",      "NL",        ""         ),
    TypeData("indent",       "Indent",    ""         ),
    TypeData("dedent",       "Dedent",    ""         ),
    TypeData("comma",        ",",         ""         ),
    TypeData("true_",        "true",      ""         ),
    TypeData("false_",       "false",     ""         ),
    TypeData("nil",          "nil",       ""         ),
    TypeData("fun",          "fun",       ""         ),
    TypeData("if_",          "if",        ""         ),
    TypeData("else_",        "else",      ""         ),
    TypeData("break_",       "break",     ""         ),
    TypeData("continue_",    "continue",  ""         ),
    TypeData("while_",       "while",     ""         ),
    TypeData("for_",         "for",       ""         ),
    TypeData("in_",          "in",        ""         ),
    TypeData("return_",      "return ",   ""         ),
    TypeData("identifier",   "id",        ""         ),
    TypeData("number",       "num",       ""         ),
    TypeData("string",       "str",       ""         ),
    TypeData("lambda",       "λ",         ""         ),
    TypeData("arrow",        "->",        ""         ),
    TypeData("lParen",       "(",         ""         ),
    TypeData("rParen",       ")",         ""         ),
    TypeData("lSquare",      "[",         ""         ),
    TypeData("rSquare",      "]",         ""         ),
    TypeData("lCurly",       "{",         ""         ),
    TypeData("rCurly",       "}",         ""         ),
    TypeData("dot",          ".",         ""         ),
    TypeData("inc",          "++",        "opInc"    ),
    TypeData("dec",          "--",        "opDec"    ),
    TypeData("plus",         "+",         "opAdd"    ),
    TypeData("minus",        "-",         "opSub"    ),
    TypeData("mply",         "*",         "opMply"   ),
    TypeData("div",          "/",         "opDiv"    ),
    TypeData("intDiv",       "//",        "opIntdiv" ),
    TypeData("mod",          "%",         "opMod"    ),
    TypeData("pow",          "**",        "opPow"    ),
    TypeData("eq",           "==",        "opEq"     ),
    TypeData("ne",           "!=",        ""         ),
    TypeData("lt",           "<",         ""         ),
    TypeData("gt",           ">",         ""         ),
    TypeData("le",           "<=",        ""         ),
    TypeData("ge",           ">=",        ""         ),
    TypeData("and",          "&&",        ""         ),
    TypeData("or",           "||",        ""         ),
    TypeData("not",          "!",         "opNot"    ),
    TypeData("xor",          "^",         "opXor"    ),
    TypeData("bAnd",         "&",         "opAnd"    ),
    TypeData("bOr",          "|",         "opOr"     ),
    TypeData("lsh",          "<<",        "opLsh"    ),
    TypeData("rsh",          ">>",        "opRsh"    ),
    TypeData("tilde",        "~",         "opCat"    ),
    TypeData("assign",       "=",         ""         ),
    TypeData("question",     "?",         ""         ),
    TypeData("colon",        ":",         ""         ),
    TypeData("catEq",        "~=",        "opCat"    ),
    TypeData("plusEq",       "+=",        "opAdd"    ),
    TypeData("minusEq",      "-=",        "opSub"    ),
    TypeData("mplyEq",       "*=",        "opMply"   ),
    TypeData("divEq",        "/=",        "opDiv"    ),
    TypeData("intDivEq",     "//=",       "opIntdiv" ),
    TypeData("modEq",        "%=",        "opMod"    ),
    TypeData("powEq",        "**=",       "opPow"    ),
    TypeData("lshEq",        "<<=",       "opLsh"    ),
    TypeData("rshEq",        ">>=",       "opRsh"    ),
    TypeData("andEq",        "&=",        "opAnd"    ),
    TypeData("xorEq",        "^=",        "opXor"    ),
    TypeData("orEq",         "|=",        "opOr"     ),
];
//dfmt on

private static string _genType() {
    auto result = "enum TT {";
    static foreach (a; typeDatas)
        result ~= a.typeName ~ ", ";
    return result ~ "}";
}

extern (C++) {
    mixin(_genType());
    struct DToken {
        TT type;
        size_t len;
        ushort* str;

        @disable this(this);
        void del();
        ~this() {
            del();
        }
    }
}
alias Token = DToken;
tsstring tsstr(const ref Token t) {
    return (cast(tschar*) t.str)[0 .. t.len].idup();
}

tsstring tsstr(const Token* t) {
    return (cast(tschar*) t.str)[0 .. t.len].idup();
}
tsstring toStr(const Token* t) {
    import ts.misc;
    final switch (t.type) {
    case TT.eof: return "EOF ";
    case TT.newLine: return "NL ";// \n";
    case TT.indent: return "→ ";
    case TT.dedent: return "←";
    case TT.comma: return ", ";
    case TT.true_: return "true";
    case TT.false_: return "false";
    case TT.nil: return "nil";
    case TT.fun: return "fun ";
    case TT.if_: return "if ";
    case TT.else_: return "else ";
    case TT.break_: return "break ";
    case TT.continue_: return "continue ";
    case TT.while_: return "while ";
    case TT.for_: return "for ";
    case TT.in_: return " in ";
    case TT.return_: return "return ";
    case TT.identifier: return t.tsstr;
    case TT.number: return t.tsstr;
    case TT.string: return tsformat!`"%s"`(t.tsstr);
    case TT.lambda: return "λ";
    case TT.arrow: return "->";
    case TT.lParen: return "(";
    case TT.rParen: return ")";
    case TT.lSquare: return "[";
    case TT.rSquare: return "]";
    case TT.lCurly: return "{";
    case TT.rCurly: return "}";
    case TT.dot: return ".";
    case TT.inc: return "++";
    case TT.dec: return "--";
    case TT.plus: return " + ";
    case TT.minus: return " - ";
    case TT.mply: return " * ";
    case TT.div: return " / ";
    case TT.intDiv: return " // ";
    case TT.mod: return " % ";
    case TT.pow: return " ** ";
    case TT.eq: return " == ";
    case TT.ne: return " != ";
    case TT.lt: return " < ";
    case TT.gt: return " > ";
    case TT.le: return " <= ";
    case TT.ge: return " >= ";
    case TT.and: return " && ";
    case TT.or: return " || ";
    case TT.not: return "!";
    case TT.xor: return " ^ ";
    case TT.bAnd: return " & ";
    case TT.bOr: return " | ";
    case TT.lsh: return " << ";
    case TT.rsh: return " >> ";
    case TT.tilde: return " ~ ";
    case TT.assign: return " = ";
    case TT.question: return "?";
    case TT.colon: return ":";
    case TT.catEq: return " ~= ";
    case TT.plusEq: return " += ";
    case TT.minusEq: return " -= ";
    case TT.mplyEq: return " *= ";
    case TT.divEq: return " /= ";
    case TT.intDivEq: return " //= ";
    case TT.modEq: return " %= ";
    case TT.powEq: return " **= ";
    case TT.lshEq: return " <<= ";
    case TT.rshEq: return " >>= ";
    case TT.andEq: return " &= ";
    case TT.xorEq: return " ^= ";
    case TT.orEq: return " |= ";

    }
    /*
    import core.stdc.stdlib : free;
    ushort* ptr;
    size_t len;
    t.toString(&ptr, &len);
    auto res = (cast(tschar*) t.str)[0 .. t.len].idup();
    free(ptr);
    return res;*/
}
tsstring toStr(const ref Token t) {
    return toStr(&t);
}

tsstring unaryFunctionName(TT type) {
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
tsstring binaryFunctionName(TT type) {
    final switch (type) {
        static foreach (a; typeDatas)
            mixin(format!`case TT.%s: return "%s";`(a.typeName, a.functionName));
    }
}

string symbolicStr(TT type) {
    final switch (type) {
        static foreach (a; typeDatas) {
            mixin(format!`case TT.%s: return "%s";`(a.typeName, a.symbolicStr));
        }
    }
}

string symbolicToTTName(string symbolic) {
    final switch (symbolic) {
        static foreach (a; typeDatas) {
            mixin(format!r"case `%s`: return `%s`;"(a.symbolicStr, a.typeName));
        }
    }
}

TT symbolicToTT(string t) {
    switch (t) {
        static foreach (a; typeDatas)
            mixin(format!r"case `%s`: return TT.%s;"(a.symbolicStr, a.typeName));
    default:
        assert(0, format!"invalid type '%s'"(t));
    }
}
