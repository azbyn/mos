#include "token.h"

#include <cstring>
#include <string>
#include <exception>


//std::to_string doesn't work on android
static std::string to_string(int x) {
    int length = snprintf(NULL, 0, "%d", x);
    Q_ASSERT(length >= 0);
    char* buf = new char[length + 1];
    snprintf(buf, length + 1, "%d", x);
    std::string str(buf);
    delete[] buf;
    return str;
}
QString Token::toString() const {
    switch (type) {
    // clang-format off
    case Type::Eof: return "EOF";
    case Type::NewLine: return "\n";
    case Type::Indent: return "INDENT";
    case Type::Dedent: return "DEDENT";
    case Type::Comma: return ",";
    case Type::This: return "this";
    case Type::True: return "true";
    case Type::False: return "false";
    case Type::Nil: return "nil";
    case Type::Struct: return "struct";
    case Type::Module: return "module";
    case Type::Import: return "import";
    case Type::Fun: return "fun";
    case Type::Prop: return "prop";
    case Type::If: return "if";
    case Type::Elif: return "elif";
    case Type::Else: return "else";
    case Type::Break: return "break";
    case Type::Continue: return "continue";
    case Type::While: return "while";
    case Type::For: return "for";
    case Type::In: return "in";
    case Type::Return: return "return";
    case Type::Identifier: return val;
    case Type::Number: return val;
    case Type::String: return QString("\"%1\"").arg(val);
    case Type::Variadic: return "...";
    case Type::Lambda: return "λ";
    case Type::Arrow: return "->";
    case Type::LParen: return "(";
    case Type::RParen: return ")";
    case Type::LSquare: return "[";
    case Type::RSquare: return "]";
    case Type::LCurly: return "{";
    case Type::RCurly: return "}";
    case Type::Dot: return ".";
    case Type::Inc: return "++";
    case Type::Dec: return "--";
    case Type::Plus: return "+";
    case Type::Minus: return "-";
    case Type::Mply: return "*";
    case Type::Div: return "/";
    case Type::IntDiv: return "//";
    case Type::Mod: return "%";
    case Type::Pow: return "**";
    case Type::Eq: return "==";
    case Type::Ne: return "!=";
    case Type::Lt: return "<";
    case Type::Gt: return ">";
    case Type::Le: return "<=";
    case Type::Ge: return ">=";
    case Type::And: return "&&";
    case Type::Or: return "||";
    case Type::Not: return "!";
    case Type::Xor: return "^";
    case Type::BAnd: return "&";
    case Type::BOr: return "|";
    case Type::Lsh: return "<<";
    case Type::Rsh: return ">>";
    case Type::Tilde: return "~";
    case Type::Assign: return "=";
    case Type::Question: return "?";
    case Type::Colon: return ":";
    case Type::CatEq: return "~=";
    case Type::PlusEq: return "+=";
    case Type::MinusEq: return "-=";
    case Type::MplyEq: return "*=";
    case Type::DivEq: return "/=";
    case Type::IntDivEq: return "//=";
    case Type::ModEq: return "%=";
    case Type::PowEq: return "**=";
    case Type::LshEq: return "<<=";
    case Type::RshEq: return ">>=";
    case Type::AndEq: return "&=";
    case Type::XorEq: return "^=";
    case Type::OrEq: return  "|=";
        // clang-format on
    }
    throw std::logic_error(std::string("INVALID ") + to_string((int)type));
}

DToken::DToken(const Token& t) : type(t.type), len(t.val.size()) {
    str = new ushort[len];
    memcpy(str, t.val.unicode(), len * sizeof(ushort));
}
void DToken::del() {
    delete[] str;
    str = nullptr;
}
bool isSpaceBetween(TT t1, TT t2) {
    if (t1 == TT::Eof) return false;
    switch (t2) {
    // clang-format off
    case TT::Eof:
    case TT::NewLine:
    case TT::Indent:
    case TT::Dedent:
        return false;
    case TT::Struct:
    case TT::Module:
    case TT::Import:
    case TT::Fun:
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

    case TT::Arrow:
    case TT::Not:
    case TT::Question:
    case TT::Plus:
    case TT::Minus:
    case TT::Mply:
    case TT::Div:
    case TT::IntDiv:
    case TT::Mod:
    case TT::Pow:
    case TT::Eq:
    case TT::Ne:
    case TT::Lt:
    case TT::Gt:
    case TT::Le:
    case TT::Ge:
    case TT::And:
    case TT::Or:
    case TT::Xor:
    case TT::BAnd:
    case TT::BOr:
    case TT::Lsh:
    case TT::Rsh:
    case TT::Tilde:
    case TT::CatEq:
    case TT::PlusEq:
    case TT::MinusEq:
    case TT::MplyEq:
    case TT::DivEq:
    case TT::IntDivEq:
    case TT::ModEq:
    case TT::PowEq:
    case TT::LshEq:
    case TT::RshEq:
    case TT::AndEq:
    case TT::XorEq:
    case TT::OrEq:
        return true;

    case TT::Number:
    case TT::String:
        switch (t1) {
        case TT::LParen:
        case TT::RParen:
        case TT::LSquare:
        case TT::LCurly:
        case TT::Not:
        case TT::Inc:
        case TT::Dec:
            return false;
        default: return true;
        }
    case TT::LParen:
    case TT::LSquare:
    case TT::LCurly:
        switch (t1) {
        case TT::Lambda:
        case TT::LParen:
        case TT::RParen:
        case TT::LSquare:
        case TT::RSquare:
        case TT::LCurly:
        case TT::RCurly:
        case TT::Not:
        case TT::Inc:
        case TT::Dec:
        case TT::Identifier:
        case TT::True:
        case TT::False:
        case TT::Nil:
        case TT::Fun:
        case TT::This:

            return false;
        default: return true;
        }
    case TT::RParen:
    case TT::RSquare:
    case TT::RCurly:
        switch (t1) {
        case TT::Number:
        case TT::String:
        case TT::True:
        case TT::This:
        case TT::False:
        case TT::Nil:
        case TT::Lambda:
        case TT::LParen:
        case TT::RParen:
        case TT::LSquare:
        case TT::Variadic:
        case TT::RSquare:
        case TT::LCurly:
        case TT::RCurly:
        case TT::Not:
        case TT::Inc:
        case TT::Dec:
        case TT::Identifier:
            return false;
        default: return true;
        }
    case TT::Dot:
        switch (t1) {
        case TT::String:
        case TT::RParen:
        case TT::RSquare:
        case TT::RCurly:
        case TT::Identifier:
            return false;
        default: return true;
        }
    case TT::Colon:
        switch (t1) {
        case TT::String:
        case TT::Number:
        case TT::Else:
        case TT::This:
        case TT::True:
        case TT::False:
        case TT::Nil:
        case TT::RParen:
        case TT::RSquare:
        case TT::RCurly:
        case TT::Inc:
        case TT::Dec:
        case TT::Identifier:
            return false;
        default: return true;
        }
    case TT::Assign:
        switch (t1) {
        case TT::Plus:
        case TT::Minus:
        case TT::Mply:
        case TT::Div:
        case TT::IntDiv:
        case TT::Mod:
        case TT::Pow:
        case TT::Eq:
        case TT::Ne:
        case TT::Lt:
        case TT::Gt:
        case TT::Le:
        case TT::Ge:
        case TT::And:
        case TT::Or:
        case TT::Xor:
        case TT::BAnd:
        case TT::BOr:
        case TT::Lsh:
        case TT::Rsh:
        case TT::Tilde:
            return false;
        default: return true;
        }

    case TT::Inc:
    case TT::Dec:
        switch (t1) {
        case TT::String:
        case TT::Number:
        case TT::LParen:
        case TT::RParen:
        case TT::LSquare:
        case TT::RSquare:
        case TT::LCurly:
        case TT::RCurly:
        case TT::This:
        case TT::True:
        case TT::False:
        case TT::Nil:
        case TT::Identifier:
            return false;
        default: return true;
        }
    case TT::This:
    case TT::True:
    case TT::False:
    case TT::Nil:
    case TT::Identifier:
        switch (t1) {
        case TT::LParen:
        case TT::LSquare:
        case TT::LCurly:
        case TT::Not:
        case TT::Inc:
        case TT::Dot:
        case TT::Dec:
            return false;
        default: return true;
        }
    case TT::Comma:
        switch (t1) {
        case TT::RParen:
        case TT::RSquare:
        case TT::RCurly:
        case TT::Identifier:
        case TT::Number:
        case TT::This:
        case TT::True:
        case TT::False:
        case TT::Nil:
            return false;
        default: return true;
        }
    case TT::Variadic:
        switch (t1) {
        case TT::Identifier:
            return false;
        default: return true;
        }
    case TT::Lambda:
        switch (t1) {
        case TT::LParen:
        case TT::LSquare:
        case TT::LCurly:
            return false;
        default: return true;
        }
    }
    return true;
}
