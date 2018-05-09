#include "token.h"

#include <cstring>

Token::Token(Type type, const QString& val) : type(type), val(val) {}
Token::Token(Type type, QString&& val) : type(type), val(std::move(val)) {}
const QChar* Token::valUtf16(int& len) const {
    len = val.size();
    return val.unicode();
}
int Token::size() const {
    return val.size();
}

const char* Token::valUtf8() const {
    auto v = val.toUtf8();
    char* cstr = (char*)malloc(val.size());
    strcpy(cstr, v.constData());
    return cstr;
}
QColor Token::color(TT nextType) const {
    switch (type) {
    case TT::eof:
    //case TT::newLine:
    case TT::terminator:
    case TT::comma:
        return colors::delimiters;
    case TT::true_:
    case TT::false_:
    case TT::nil:
    case TT::fun:
    case TT::if_:
    case TT::else_:
    case TT::break_:
    case TT::continue_:
    case TT::while_:
    case TT::for_:
    case TT::in_:
    case TT::return_:
        return colors::keywords;
    case TT::identifier:
        return nextType == TT::lParen ? colors::functions : colors::variables;
    case TT::number: return colors::numbers;
    case TT::string: return colors::strings;
    case TT::lambda:
    case TT::arrow:
        return colors::operators;
    case TT::lParen:
    case TT::rParen:
    case TT::lSquare:
    case TT::rSquare:
    case TT::lCurly:
    case TT::rCurly:
        return colors::brackets;
    default:
        return colors::operators;
    }
}

QString Token::toString() const {
    switch (type) {
    // clang-format off
    case Type::eof: return "EOF";
    //case Type::newLine: return "\n";
    case Type::terminator: return ";";
    case Type::comma: return ", ";
    case Type::true_: return "true";
    case Type::false_: return "false";
    case Type::nil: return "nil";
    case Type::fun: return "fun ";
    case Type::if_: return "if ";
    case Type::else_: return "else ";
    case Type::break_: return "break ";
    case Type::continue_: return "continue ";
    case Type::while_: return "while ";
    case Type::for_: return "for ";
    case Type::in_: return " in ";
    case Type::return_: return "return ";
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
    case Type::plus: return " + ";
    case Type::minus: return " - ";
    case Type::mply: return " * ";
    case Type::div: return " / ";
    case Type::intDiv: return " // ";
    case Type::mod: return " % ";
    case Type::pow: return " ** ";
    case Type::eq: return " == ";
    case Type::ne: return " != ";
    case Type::lt: return " < ";
    case Type::gt: return " > ";
    case Type::le: return " <= ";
    case Type::ge: return " >= ";
    case Type::and_: return " && ";
    case Type::or_: return " || ";
    case Type::not_: return "!";
    case Type::xor_: return " ^ ";
    case Type::bAnd: return " & ";
    case Type::bOr: return " | ";
    case Type::lsh: return " << ";
    case Type::rsh: return " >> ";
    case Type::tilde: return " ~ ";
    case Type::assign: return " = ";
    case Type::question: return "?";
    case Type::colon: return ":";
    case Type::catEq: return " ~= ";
    case Type::plusEq: return " += ";
    case Type::minusEq: return " -= ";
    case Type::mplyEq: return " *= ";
    case Type::divEq: return " /= ";
    case Type::intDivEq: return " //= ";
    case Type::modEq: return " %= ";
    case Type::powEq: return " **= ";
    case Type::lshEq: return " <<= ";
    case Type::rshEq: return " >>= ";
    case Type::andEq: return " &= ";
    case Type::xorEq: return " ^= ";
    case Type::orEq: return " |= ";
        // clang-format on
    }
    throw "INVALID";
}
