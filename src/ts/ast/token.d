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
    TypeData("Eof",          "EOF",       ""         ),//only used by parser
    TypeData("NewLine",      "NL",        ""         ),
    TypeData("Indent",       "Indent",    ""         ),
    TypeData("Dedent",       "Dedent",    ""         ),
    TypeData("Comma",        ",",         ""         ),
    TypeData("True",         "true",      ""         ),
    TypeData("False",        "false",     ""         ),
    TypeData("Nil",          "nil",       ""         ),
    TypeData("Struct",       "struct",    ""         ),
    TypeData("Fun",          "fun",       ""         ),
    TypeData("Prop",         "prop",      ""         ),
    TypeData("If",           "if",        ""         ),
    TypeData("Elif",         "elif",      ""         ),
    TypeData("Else",         "else",      ""         ),
    TypeData("Break",        "break",     ""         ),
    TypeData("Continue",     "continue",  ""         ),
    TypeData("While",        "while",     ""         ),
    TypeData("For",          "for",       ""         ),
    TypeData("In",           "in",        ""         ),
    TypeData("Return",       "return ",   ""         ),
    TypeData("Identifier",   "id",        ""         ),
    TypeData("Number",       "num",       ""         ),
    TypeData("String",       "str",       ""         ),
    TypeData("Lambda",       "λ",         ""         ),
    TypeData("Arrow",        "->",        ""         ),
    TypeData("LParen",       "(",         ""         ),
    TypeData("RParen",       ")",         ""         ),
    TypeData("LSquare",      "[",         ""         ),
    TypeData("RSquare",      "]",         ""         ),
    TypeData("LCurly",       "{",         ""         ),
    TypeData("RCurly",       "}",         ""         ),
    TypeData("Dot",          ".",         ""         ),
    TypeData("Inc",          "++",        "opInc"    ),
    TypeData("Dec",          "--",        "opDec"    ),
    TypeData("Plus",         "+",         "opAdd"    ),
    TypeData("Minus",        "-",         "opSub"    ),
    TypeData("Mply",         "*",         "opMply"   ),
    TypeData("Div",          "/",         "opDiv"    ),
    TypeData("IntDiv",       "//",        "opIntdiv" ),
    TypeData("Mod",          "%",         "opMod"    ),
    TypeData("Pow",          "**",        "opPow"    ),
    TypeData("Eq",           "==",        "opEq"     ),
    TypeData("Ne",           "!=",        ""         ),
    TypeData("Lt",           "<",         ""         ),
    TypeData("Gt",           ">",         ""         ),
    TypeData("Le",           "<=",        ""         ),
    TypeData("Ge",           ">=",        ""         ),
    TypeData("And",          "&&",        ""         ),
    TypeData("Or",           "||",        ""         ),
    TypeData("Not",          "!",         "opNot"    ),
    TypeData("Xor",          "^",         "opXor"    ),
    TypeData("BAnd",         "&",         "opAnd"    ),
    TypeData("BOr",          "|",         "opOr"     ),
    TypeData("Lsh",          "<<",        "opLsh"    ),
    TypeData("Rsh",          ">>",        "opRsh"    ),
    TypeData("Tilde",        "~",         "opCat"    ),
    TypeData("Assign",       "=",         ""         ),
    TypeData("Question",     "?",         ""         ),
    TypeData("Colon",        ":",         ""         ),
    TypeData("CatEq",        "~=",        "opCat"    ),
    TypeData("PlusEq",       "+=",        "opAdd"    ),
    TypeData("MinusEq",      "-=",        "opSub"    ),
    TypeData("MplyEq",       "*=",        "opMply"   ),
    TypeData("DivEq",        "/=",        "opDiv"    ),
    TypeData("IntDivEq",     "//=",       "opIntdiv" ),
    TypeData("ModEq",        "%=",        "opMod"    ),
    TypeData("PowEq",        "**=",       "opPow"    ),
    TypeData("LshEq",        "<<=",       "opLsh"    ),
    TypeData("RshEq",        ">>=",       "opRsh"    ),
    TypeData("AndEq",        "&=",        "opAnd"    ),
    TypeData("XorEq",        "^=",        "opXor"    ),
    TypeData("OrEq",         "|=",        "opOr"     ),
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
    case TT.Eof: return "EOF ";
    case TT.NewLine: return "NL ";// \n";
    case TT.Indent: return "→ ";
    case TT.Dedent: return "←";
    case TT.Comma: return ", ";
    case TT.True: return "true";
    case TT.False: return "false";
    case TT.Nil: return "nil";
    case TT.Struct: return "struct ";
    case TT.Fun: return "fun ";
    case TT.Prop: return "prop ";
    case TT.If: return "if ";
    case TT.Elif: return "elif ";
    case TT.Else: return "else ";
    case TT.Break: return "break ";
    case TT.Continue: return "continue ";
    case TT.While: return "while ";
    case TT.For: return "for ";
    case TT.In: return " in ";
    case TT.Return: return "return ";
    case TT.Identifier: return t.tsstr;
    case TT.Number: return t.tsstr;
    case TT.String: return tsformat!`"%s"`(t.tsstr);
    case TT.Lambda: return "λ";
    case TT.Arrow: return "->";
    case TT.LParen: return "(";
    case TT.RParen: return ")";
    case TT.LSquare: return "[";
    case TT.RSquare: return "]";
    case TT.LCurly: return "{";
    case TT.RCurly: return "}";
    case TT.Dot: return ".";
    case TT.Inc: return "++";
    case TT.Dec: return "--";
    case TT.Plus: return " + ";
    case TT.Minus: return " - ";
    case TT.Mply: return " * ";
    case TT.Div: return " / ";
    case TT.IntDiv: return " // ";
    case TT.Mod: return " % ";
    case TT.Pow: return " ** ";
    case TT.Eq: return " == ";
    case TT.Ne: return " != ";
    case TT.Lt: return " < ";
    case TT.Gt: return " > ";
    case TT.Le: return " <= ";
    case TT.Ge: return " >= ";
    case TT.And: return " && ";
    case TT.Or: return " || ";
    case TT.Not: return "!";
    case TT.Xor: return " ^ ";
    case TT.BAnd: return " & ";
    case TT.BOr: return " | ";
    case TT.Lsh: return " << ";
    case TT.Rsh: return " >> ";
    case TT.Tilde: return " ~ ";
    case TT.Assign: return " = ";
    case TT.Question: return "?";
    case TT.Colon: return ":";
    case TT.CatEq: return " ~= ";
    case TT.PlusEq: return " += ";
    case TT.MinusEq: return " -= ";
    case TT.MplyEq: return " *= ";
    case TT.DivEq: return " /= ";
    case TT.IntDivEq: return " //= ";
    case TT.ModEq: return " %= ";
    case TT.PowEq: return " **= ";
    case TT.LshEq: return " <<= ";
    case TT.RshEq: return " >>= ";
    case TT.AndEq: return " &= ";
    case TT.XorEq: return " ^= ";
    case TT.OrEq: return " |= ";
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
    case TT.Plus: return "opPlus";
    case TT.Minus: return "opMinus";
    case TT.Inc: return "opInc";
    case TT.Dec: return "opDec";
    case TT.Not: return "opNot";
    case TT.Tilde: return "opCom";
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
