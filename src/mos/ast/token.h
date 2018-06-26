#ifndef MOS_TOKEN_H
#define MOS_TOKEN_H

#include "colors.h"
enum class TT {
    Eof,
    NewLine,
    Indent,
    Dedent,
    Comma,
    This,
    True,
    False,
    Nil,
    Struct,
    Module,
    Import,
    Fun,
    Prop,
    If,
    Elif,
    Else,
    Break,
    Continue,
    While,
    For,
    In,
    Return,
    Identifier,
    Number,
    String,
    Variadic,
    Lambda,
    Arrow,
    LParen,
    RParen,
    LSquare,
    RSquare,
    LCurly,
    RCurly,
    Dot,
    Inc,
    Dec,
    Plus,
    Minus,
    Mply,
    Div,
    IntDiv,
    Mod,
    Pow,
    Eq,
    Ne,
    Lt,
    Gt,
    Le,
    Ge,
    And,
    Or,
    Not,
    Xor,
    BAnd,
    BOr,
    Lsh,
    Rsh,
    Tilde,
    Assign,
    Question,
    Colon,
    CatEq,
    PlusEq,
    MinusEq,
    MplyEq,
    DivEq,
    IntDivEq,
    ModEq,
    PowEq,
    LshEq,
    RshEq,
    AndEq,
    XorEq,
    OrEq,
};
bool isSpaceBetween(TT t1, TT t2);

struct Token {
    using Type = TT;
    Type type;
    QString val;
    explicit Token(TT type) : type(type), val("") {}
    Token(Type type, const QString& val)
        : type(type), val(val) {}
    Token(Type type, QString&& val)
        : type(type), val(std::move(val)) {}

    QString toString() const;
    template<typename F>
    QColor color(TT prevType, F nextType) const;

};
struct DToken {
    TT type;
    size_t len;
    ushort* str;
    explicit DToken(TT tt) : type(tt), len(0), str(nullptr) {}
    explicit DToken(const Token& t);

    void del();
};

template<typename F>
QColor Token::color(TT prevType, F nextType) const {
    switch (type) {
    case TT::Eof:
    case TT::NewLine:
    case TT::Indent:
    case TT::Dedent:
    case TT::Comma:
    case TT::Variadic:
        return colors::Delimiters;
    case TT::True:
    case TT::False:
    case TT::Nil:
        return colors::Constants;
    case TT::Fun:
    case TT::Struct:
    case TT::Import:
    case TT::Module:
    case TT::Prop:
    case TT::If:
    case TT::Elif:
    case TT::Else:
    case TT::Break:
    case TT::Continue:
    case TT::While:
    case TT::For:
    case TT::In:
    case TT::Return:
    case TT::Lambda:
    case TT::Arrow:
    case TT::This:
        return colors::Keywords;
    case TT::Identifier:
        return nextType() == TT::LParen || prevType == TT::Fun || prevType == TT::Prop ?
            colors::Functions : colors::Variables;
    case TT::Number: return colors::Numbers;
    case TT::String: return colors::Strings;
        return colors::Operators;
    case TT::LParen:
    case TT::RParen:
    case TT::LSquare:
    case TT::RSquare:
    case TT::LCurly:
    case TT::RCurly:
        return colors::Brackets;
    default:
        return colors::Operators;
    }
}

using TT = Token::Type;

#endif //MOS_TOKEN_H
