#!/usr/bin/env perl

# it's messier to implement this in D because of toStringz and
# because string literals aren't implicitly converted to const(char)*
# perl is also great for string manipulation

use strict;
use warnings;

sub reprStr {
    my ($name) = @_;
    return "\"$name\"";
}
sub reprExpr {
    my ($expr) = @_;
    return $expr;
}
my $str = "val";
my @typeDatas = (
        #0            1            2              3
        #typename,    symbolcStr,  functionName,  editorReprFun
        ["eof",          "EOF",       "",         reprStr("EOF")],#only used by parser
        ["newLine",      "NL",        "",         reprStr("\\n")],
        ["terminator",   ";",         "",         reprStr(";")],
        ["comma",        ",",         "",         reprStr(", ")],
        ["true_",        "true",      "",         reprStr("true")],
        ["false_",       "false",     "",         reprStr("false")],
        ["nil",          "nil",       "",         reprStr("nil")],
        ["fun",          "fun",       "",         reprStr("fun ")],
        ["if_",          "if",        "",         reprStr("if ")],
        ["else_",        "else",      "",         reprStr("else ")],
        ["break_",       "break",     "",         reprStr("break ")],
        ["continue_",    "continue",  "",         reprStr("continue ")],
        ["while_",       "while",     "",         reprStr("while ")],
        ["for_",         "for",       "",         reprStr("for ")],
        ["in_",          "in",        "",         reprStr(" in ")],
        ["return_",      "return ",   "",         reprStr("return ")],
        ["identifier",   "id",        "",         reprExpr("$str")],
        ["number",       "num",       "",         reprExpr("$str")],
        ["string",       "str",       "",         reprExpr('QString("\"%s\"").arg('.$str.')')],
        ["lambda",       "λ",         "",         reprStr("λ")],
        ["arrow",        "->",        "",         reprStr("->")],
        ["lParen",       "(",         "",         reprStr("(")],
        ["rParen",       ")",         "",         reprStr(")")],
        ["lSquare",      "[",         "",         reprStr("[")],
        ["rSquare",      "]",         "",         reprStr("]")],
        ["lCurly",       "{",         "",         reprStr("{")],
        ["rCurly",       "}",         "",         reprStr("}")],
        ["dot",          ".",         "",         reprStr(".")],
        ["inc",          "++",        "opInc",    reprStr("++")],
        ["dec",          "--",        "opDec",    reprStr("--")],
        ["plus",         "+",         "opAdd",    reprStr(" + ")],
        ["minus",        "-",         "opSub",    reprStr(" - ")],
        ["mply",         "*",         "opMply",   reprStr(" * ")],
        ["div",          "/",         "opDiv",    reprStr(" / ")],
        ["intDiv",       "//",        "opIntdiv", reprStr(" // ")],
        ["mod",          "%",         "opMod",    reprStr(" % ")],
        ["pow",          "**",        "opPow",    reprStr(" ** ")],
        ["eq",           "==",        "opEq",     reprStr(" == ")],
        ["ne",           "!=",        "",         reprStr(" != ")],
        ["lt",           "<",         "",         reprStr(" < ")],
        ["gt",           ">",         "",         reprStr(" > ")],
        ["le",           "<=",        "",         reprStr(" <= ")],
        ["ge",           ">=",        "",         reprStr(" >= ")],
        ["and_",         "&&",        "",         reprStr(" && ")],
        ["or_",          "||",        "",         reprStr(" || ")],
        ["not_",         "!",         "opNot",    reprStr("!")],
        ["xor_",         "^",         "opXor",    reprStr(" ^ ")],
        ["bAnd",         "&",         "opAnd",    reprStr(" & ")],
        ["bOr",          "|",         "opOr",     reprStr(" | ")],
        ["lsh",          "<<",        "opLsh",    reprStr(" << ")],
        ["rsh",          ">>",        "opRsh",    reprStr(" >> ")],
        ["tilde",        "~",         "opCat",    reprStr(" ~ ")],
        ["assign",       "=",         "",         reprStr(" = " )],
        ["question",     "?",         "",         reprStr("?")],
        ["colon",        ":",         "",         reprStr(":")],
        ["catEq",        "~=",        "opCat",    reprStr(" ~= ")],
        ["plusEq",       "+=",        "opAdd",    reprStr(" += ")],
        ["minusEq",      "-=",        "opSub",    reprStr(" -= ")],
        ["mplyEq",       "*=",        "opMply",   reprStr(" *= ")],
        ["divEq",        "/=",        "opDiv",    reprStr(" /= ")],
        ["intDivEq",     "//=",       "opIntdiv", reprStr(" //= ")],
        ["modEq",        "%=",        "opMod",    reprStr(" %= ")],
        ["powEq",        "**=",       "opPow",    reprStr(" **= ")],
        ["lshEq",        "<<=",       "opLsh",    reprStr(" <<= ")],
        ["rshEq",        ">>=",       "opRsh",    reprStr(" >>= ")],
        ["andEq",        "&=",        "opAnd",    reprStr(" &= ")],
        ["xorEq",        "^=",        "opXor",    reprStr(" ^= ")],
        ["orEq",         "|=",        "opOr",     reprStr(" |= ")],
        #typename,    symbolcStr,  functionName,  editorReprFun
        #0            1            2              3
    );

my $I="    ";#indent

sub cpp {
    my $GUARD="TS_TOKEN_H";

    print <<"END";
#ifndef $GUARD
#define $GUARD

#include <QString>

namespace ts {
struct Token {
    enum class Type {
END
    for my $i (@typeDatas) {
        print (($I x 2)."$i->[0],\n");
    }

    print <<"END";
    };
    Type type;
    QString $str;
    Token(Type type, QString val = "") : type(type), $str(val) {}
    QString toString() const {
        switch (type) {
            // clang-format off
END
    for my $i (@typeDatas) {
        print (($I x 3)."case Type::$i->[0]: return $i->[3];\n");
    }
    print <<"END";
            // clang-format on
        }
    }
    const QChar* ${str}Utf16(int& len) const {
        len = $str.size();
        return $str.unicode();
    }
};

END
    for my $i (@typeDatas) {
        my $name = $i->[0];
        if ($name =~ /(.*)_$/) {
            $name = $1;
        }
        print <<"FUN";
inline Token tok_$name(QString s = "") { return Token(Token::Type::$i->[0], s); }
FUN
}

    print <<"END";

using TT = Token::Type;
} // namespace ts

#endif //$GUARD
END
}
sub dlang {
=pod
/*
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

*/

=cut

    printf <<"END";
module ts.ast.token;

import std.format;
import qte5;

alias Pos = int;
alias TT = Token.Type;


extern(C++, ts):
struct Token {
    enum Type {
END
    for my $i (@typeDatas) {
        print (($I x 2)."$i->[0],\n");
    }
    printf <<"END";
    }
    Type type;
    QString str;

    QString toString() const;
    const(wchar)* ${str}Utf16(ref int len) const;
}
END

}
dlang();
