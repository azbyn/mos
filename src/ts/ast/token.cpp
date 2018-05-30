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
    case Type::eof: return "EOF";
    case Type::newLine: return "\n";
    case Type::indent: return "INDENT";
    case Type::dedent: return "DEDENT";
    case Type::comma: return ",";
    case Type::true_: return "true";
    case Type::false_: return "false";
    case Type::nil: return "nil";
    case Type::fun: return "fun";
    case Type::if_: return "if";
    case Type::else_: return "else";
    case Type::break_: return "break";
    case Type::continue_: return "continue";
    case Type::while_: return "while";
    case Type::for_: return "for";
    case Type::in: return "in";
    case Type::return_: return "return";
    case Type::identifier: return val;
    case Type::number: return val;
    case Type::string: return QString("\"%1\"").arg(val);
    case Type::lambda: return "λ";
    case Type::arrow: return "->";
    case Type::lParen: return "(";
    case Type::rParen: return ")";
    case Type::lSquare: return "[";
    case Type::rSquare: return "]";
    case Type::lCurly: return "{";
    case Type::rCurly: return "}";
    case Type::dot: return ".";
    case Type::inc: return "++";
    case Type::dec: return "--";
    case Type::plus: return "+";
    case Type::minus: return "-";
    case Type::mply: return "*";
    case Type::div: return "/";
    case Type::intDiv: return "//";
    case Type::mod: return "%";
    case Type::pow: return "**";
    case Type::eq: return "==";
    case Type::ne: return "!=";
    case Type::lt: return "<";
    case Type::gt: return ">";
    case Type::le: return "<=";
    case Type::ge: return ">=";
    case Type::and_: return "&&";
    case Type::or_: return "||";
    case Type::not_: return "!";
    case Type::xor_: return "^";
    case Type::bAnd: return "&";
    case Type::bOr: return "|";
    case Type::lsh: return "<<";
    case Type::rsh: return ">>";
    case Type::tilde: return "~";
    case Type::assign: return "=";
    case Type::question: return "?";
    case Type::colon: return ":";
    case Type::catEq: return "~=";
    case Type::plusEq: return "+=";
    case Type::minusEq: return "-=";
    case Type::mplyEq: return "*=";
    case Type::divEq: return "/=";
    case Type::intDivEq: return "//=";
    case Type::modEq: return "%=";
    case Type::powEq: return "**=";
    case Type::lshEq: return "<<=";
    case Type::rshEq: return ">>=";
    case Type::andEq: return "&=";
    case Type::xorEq: return "^=";
    case Type::orEq: return  "|=";
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
    if (t1 == TT::eof) return false;
    switch (t2) {
    // clang-format off
    case TT::eof:
    case TT::newLine:
    case TT::indent:
    case TT::dedent:
        return false;
    case TT::fun:
    case TT::if_:
    case TT::else_:
    case TT::break_:
    case TT::continue_:
    case TT::while_:
    case TT::for_:
    case TT::in:
    case TT::return_:

    case TT::arrow:
    case TT::not_:
    case TT::question:
    case TT::plus:
    case TT::minus:
    case TT::mply:
    case TT::div:
    case TT::intDiv:
    case TT::mod:
    case TT::pow:
    case TT::eq:
    case TT::ne:
    case TT::lt:
    case TT::gt:
    case TT::le:
    case TT::ge:
    case TT::and_:
    case TT::or_:
    case TT::xor_:
    case TT::bAnd:
    case TT::bOr:
    case TT::lsh:
    case TT::rsh:
    case TT::tilde:
    case TT::catEq:
    case TT::plusEq:
    case TT::minusEq:
    case TT::mplyEq:
    case TT::divEq:
    case TT::intDivEq:
    case TT::modEq:
    case TT::powEq:
    case TT::lshEq:
    case TT::rshEq:
    case TT::andEq:
    case TT::xorEq:
    case TT::orEq:
        return true;

    case TT::number:
    case TT::string:
        switch (t1) {
        case TT::lParen:
        case TT::rParen:
        case TT::lSquare:
        case TT::lCurly:
        case TT::not_:
        case TT::inc:
        case TT::dec:
            return false;
        default: return true;
        }
    case TT::lParen:
    case TT::lSquare:
    case TT::lCurly:
        switch (t1) {
        case TT::lambda:
        case TT::lParen:
        case TT::rParen:
        case TT::lSquare:
        case TT::rSquare:
        case TT::lCurly:
        case TT::rCurly:
        case TT::not_:
        case TT::inc:
        case TT::dec:
        case TT::identifier:
        case TT::true_:
        case TT::false_:
        case TT::nil:
        case TT::fun:

            return false;
        default: return true;
        }
    case TT::rParen:
    case TT::rSquare:
    case TT::rCurly:
        switch (t1) {
        case TT::number:
        case TT::string:
        case TT::true_:
        case TT::false_:
        case TT::nil:
        case TT::lambda:
        case TT::lParen:
        case TT::rParen:
        case TT::lSquare:
        case TT::rSquare:
        case TT::lCurly:
        case TT::rCurly:
        case TT::not_:
        case TT::inc:
        case TT::dec:
        case TT::identifier:
            return false;
        default: return true;
        }
    case TT::dot:
        switch (t1) {
        case TT::string:
        case TT::rParen:
        case TT::rSquare:
        case TT::rCurly:
        case TT::identifier:
            return false;
        default: return true;
        }
    case TT::colon:
        switch (t1) {
        case TT::string:
        case TT::number:
        case TT::true_:
        case TT::false_:
        case TT::nil:
        case TT::rParen:
        case TT::rSquare:
        case TT::rCurly:
        case TT::inc:
        case TT::dec:
        case TT::identifier:
            return false;
        default: return true;
        }
    case TT::assign:
        switch (t1) {
        case TT::plus:
        case TT::minus:
        case TT::mply:
        case TT::div:
        case TT::intDiv:
        case TT::mod:
        case TT::pow:
        case TT::eq:
        case TT::ne:
        case TT::lt:
        case TT::gt:
        case TT::le:
        case TT::ge:
        case TT::and_:
        case TT::or_:
        case TT::xor_:
        case TT::bAnd:
        case TT::bOr:
        case TT::lsh:
        case TT::rsh:
        case TT::tilde:
            return false;
        default: return true;
        }

    case TT::inc:
    case TT::dec:
        switch (t1) {
        case TT::string:
        case TT::number:
        case TT::lParen:
        case TT::rParen:
        case TT::lSquare:
        case TT::rSquare:
        case TT::lCurly:
        case TT::rCurly:
        case TT::true_:
        case TT::false_:
        case TT::nil:
        case TT::identifier:
            return false;
        default: return true;
        }
    case TT::true_:
    case TT::false_:
    case TT::nil:
    case TT::identifier:
        switch (t1) {
        case TT::lParen:
        case TT::lSquare:
        case TT::lCurly:
        case TT::not_:
        case TT::inc:
        case TT::dot:
        case TT::dec:
            return false;
        default: return true;
        }
    case TT::comma:
        switch (t1) {
        case TT::rParen:
        case TT::rSquare:
        case TT::rCurly:
        case TT::identifier:
        case TT::number:
        case TT::true_:
        case TT::false_:
        case TT::nil:
            return false;
        default: return true;
        }

    case TT::lambda:
        switch (t1) {
        case TT::lParen:
        case TT::lSquare:
        case TT::lCurly:
            return false;
        default: return true;
        }
    }
    return true;
}
