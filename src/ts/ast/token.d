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
    TypeData("terminator",   ";",         ""         ),
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
        void toString(ushort** outStr, size_t* outLen) const;
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
    import core.stdc.stdlib : free;
    ushort* ptr;
    size_t len;
    t.toString(&ptr, &len);
    auto res = (cast(tschar*) t.str)[0 .. t.len].idup();
    free(ptr);
    return res;
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
