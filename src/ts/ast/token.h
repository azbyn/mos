#ifndef TS_TOKEN_H
#define TS_TOKEN_H

#include "colors.h"
enum class TT {
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
};

struct Token {
    using Type = TT;
    Type type;
    QString val;

    Token(Type type, const QString& val = "")
        : type(type), val(val) {}
    Token(Type type, QString&& val = "")
        : type(type), val(std::move(val)) {}

    QString toString() const;
    QColor color(Type nextType) const;
};
struct DToken {
    TT type;
    size_t len;
    ushort* str;
    explicit DToken(TT tt) : type(tt), len(0), str(nullptr) {}
    explicit DToken(const Token& t);

    //DToken(const DToken&) = delete;
    //DToken(DToken&&) = delete;
    //DToken& operator=(const DToken&) = delete;
    //DToken& operator=(DToken&&) = delete;
    void toString(ushort** str, size_t* len) const;
    void del();
};
//inline Token tok_eof(QString s = "") { return Token(Token::Type::eof, s); }
inline Token tok_newLine(QString s = "") { return Token(Token::Type::newLine, s); }
inline Token tok_terminator(QString s = "") { return Token(Token::Type::terminator, s); }
inline Token tok_comma(QString s = "") { return Token(Token::Type::comma, s); }
inline Token tok_true(QString s = "") { return Token(Token::Type::true_, s); }
inline Token tok_false(QString s = "") { return Token(Token::Type::false_, s); }
inline Token tok_nil(QString s = "") { return Token(Token::Type::nil, s); }
inline Token tok_fun(QString s = "") { return Token(Token::Type::fun, s); }
inline Token tok_if(QString s = "") { return Token(Token::Type::if_, s); }
inline Token tok_else(QString s = "") { return Token(Token::Type::else_, s); }
inline Token tok_break(QString s = "") { return Token(Token::Type::break_, s); }
inline Token tok_continue(QString s = "") { return Token(Token::Type::continue_, s); }
inline Token tok_while(QString s = "") { return Token(Token::Type::while_, s); }
inline Token tok_for(QString s = "") { return Token(Token::Type::for_, s); }
inline Token tok_in(QString s = "") { return Token(Token::Type::in_, s); }
inline Token tok_return(QString s = "") { return Token(Token::Type::return_, s); }
inline Token tok_identifier(QString s = "") { return Token(Token::Type::identifier, s); }
inline Token tok_number(QString s = "") { return Token(Token::Type::number, s); }
inline Token tok_string(QString s = "") { return Token(Token::Type::string, s); }
inline Token tok_lambda(QString s = "") { return Token(Token::Type::lambda, s); }
inline Token tok_arrow(QString s = "") { return Token(Token::Type::arrow, s); }
inline Token tok_lParen(QString s = "") { return Token(Token::Type::lParen, s); }
inline Token tok_rParen(QString s = "") { return Token(Token::Type::rParen, s); }
inline Token tok_lSquare(QString s = "") { return Token(Token::Type::lSquare, s); }
inline Token tok_rSquare(QString s = "") { return Token(Token::Type::rSquare, s); }
inline Token tok_lCurly(QString s = "") { return Token(Token::Type::lCurly, s); }
inline Token tok_rCurly(QString s = "") { return Token(Token::Type::rCurly, s); }
inline Token tok_dot(QString s = "") { return Token(Token::Type::dot, s); }
inline Token tok_inc(QString s = "") { return Token(Token::Type::inc, s); }
inline Token tok_dec(QString s = "") { return Token(Token::Type::dec, s); }
inline Token tok_plus(QString s = "") { return Token(Token::Type::plus, s); }
inline Token tok_minus(QString s = "") { return Token(Token::Type::minus, s); }
inline Token tok_mply(QString s = "") { return Token(Token::Type::mply, s); }
inline Token tok_div(QString s = "") { return Token(Token::Type::div, s); }
inline Token tok_intDiv(QString s = "") { return Token(Token::Type::intDiv, s); }
inline Token tok_mod(QString s = "") { return Token(Token::Type::mod, s); }
inline Token tok_pow(QString s = "") { return Token(Token::Type::pow, s); }
inline Token tok_eq(QString s = "") { return Token(Token::Type::eq, s); }
inline Token tok_ne(QString s = "") { return Token(Token::Type::ne, s); }
inline Token tok_lt(QString s = "") { return Token(Token::Type::lt, s); }
inline Token tok_gt(QString s = "") { return Token(Token::Type::gt, s); }
inline Token tok_le(QString s = "") { return Token(Token::Type::le, s); }
inline Token tok_ge(QString s = "") { return Token(Token::Type::ge, s); }
inline Token tok_and(QString s = "") { return Token(Token::Type::and_, s); }
inline Token tok_or(QString s = "") { return Token(Token::Type::or_, s); }
inline Token tok_not(QString s = "") { return Token(Token::Type::not_, s); }
inline Token tok_xor(QString s = "") { return Token(Token::Type::xor_, s); }
inline Token tok_bAnd(QString s = "") { return Token(Token::Type::bAnd, s); }
inline Token tok_bOr(QString s = "") { return Token(Token::Type::bOr, s); }
inline Token tok_lsh(QString s = "") { return Token(Token::Type::lsh, s); }
inline Token tok_rsh(QString s = "") { return Token(Token::Type::rsh, s); }
inline Token tok_tilde(QString s = "") { return Token(Token::Type::tilde, s); }
inline Token tok_assign(QString s = "") { return Token(Token::Type::assign, s); }
inline Token tok_question(QString s = "") { return Token(Token::Type::question, s); }
inline Token tok_colon(QString s = "") { return Token(Token::Type::colon, s); }
inline Token tok_catEq(QString s = "") { return Token(Token::Type::catEq, s); }
inline Token tok_plusEq(QString s = "") { return Token(Token::Type::plusEq, s); }
inline Token tok_minusEq(QString s = "") { return Token(Token::Type::minusEq, s); }
inline Token tok_mplyEq(QString s = "") { return Token(Token::Type::mplyEq, s); }
inline Token tok_divEq(QString s = "") { return Token(Token::Type::divEq, s); }
inline Token tok_intDivEq(QString s = "") { return Token(Token::Type::intDivEq, s); }
inline Token tok_modEq(QString s = "") { return Token(Token::Type::modEq, s); }
inline Token tok_powEq(QString s = "") { return Token(Token::Type::powEq, s); }
inline Token tok_lshEq(QString s = "") { return Token(Token::Type::lshEq, s); }
inline Token tok_rshEq(QString s = "") { return Token(Token::Type::rshEq, s); }
inline Token tok_andEq(QString s = "") { return Token(Token::Type::andEq, s); }
inline Token tok_xorEq(QString s = "") { return Token(Token::Type::xorEq, s); }
inline Token tok_orEq(QString s = "") { return Token(Token::Type::orEq, s); }

using TT = Token::Type;

#endif //TS_TOKEN_H
