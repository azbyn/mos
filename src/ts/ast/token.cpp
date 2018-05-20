#include "token.h"

#include <cstring>
#include <exception>

/*const QChar* Token::valUtf16(int& len) const {
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
*/

QString Token::toString() const {
    switch (type) {
    // clang-format off
    case Type::eof: return "EOF";
    case Type::newLine: return "\n";
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
    case Type::in: return " in ";
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
    throw std::logic_error("INVALID");
}

DToken::DToken(const Token& t) : type(t.type), len(t.val.size()) {
    str = new ushort[len];
    memcpy(str, t.val.unicode(), len * sizeof(ushort));
}
void DToken::del() {
    delete[] str;
    str = nullptr;
}
