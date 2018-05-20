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
QColor Token::color(TT nextType) const {
    switch (type) {
    case TT::eof:
    case TT::newLine:
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
    case TT::in:
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

static void qStringToTsString(const QString& in, ushort** out, size_t* outLen) {
    *outLen = in.size();
    *out = (ushort*)malloc(*outLen * sizeof(ushort));
    memcpy(*out, in.unicode(), *outLen * sizeof(ushort));

}

DToken::DToken(const Token& t) :type(t.type) {
    qStringToTsString(t.val, &str, &len);
}
void DToken::del() {
    delete[] str;
    str = nullptr;
}
void DToken::toString(ushort** outStr, size_t* outLen) const {
    auto t = Token(type, QString::fromUtf16(str, len));
    qStringToTsString(t.toString(), outStr, outLen);
    /*
    auto returnStr = [outStr=outStr, outLen=outLen](auto s) {
        qStringToTsString(s, outStr, outLen);
    };
    switch (type) {
    // clang-format off
    case TT::eof:        returnStr("EOF"); break;
    case TT::newLine:    returnStr("\n"); break;
    case TT::terminator: returnStr(";"); break;
    case TT::comma:      returnStr(", "); break;
    case TT::true_:      returnStr("true"); break;
    case TT::false_:     returnStr("false"); break;
    case TT::nil:        returnStr("nil"); break;
    case TT::fun:        returnStr("fun "); break;
    case TT::if_:        returnStr("if "); break;
    case TT::else_:      returnStr("else "); break;
    case TT::break_:     returnStr("break "); break;
    case TT::continue_:  returnStr("continue "); break;
    case TT::while_:     returnStr("while "); break;
    case TT::for_:       returnStr("for "); break;
    case TT::in_:        returnStr(" in "); break;
    case TT::return_:    returnStr("return "); break;
    case TT::identifier: *outStr = str; *outLen = len; break;
    case TT::number:     *outStr = str; *outLen = len; break;
    case TT::string:     returnStr(QString("\"%1\"").arg(QString::fromUtf16(str, len))); break;
    case TT::lambda:     returnStr("λ"); break;
    case TT::arrow:      returnStr("->"); break;
    case TT::lParen:     returnStr("("); break;
    case TT::rParen:     returnStr(")"); break;
    case TT::lSquare:    returnStr("["); break;
    case TT::rSquare:    returnStr("]"); break;
    case TT::lCurly:     returnStr("{"); break;
    case TT::rCurly:     returnStr("}"); break;
    case TT::dot:        returnStr("."); break;
    case TT::inc:        returnStr("++"); break;
    case TT::dec:        returnStr("--"); break;
    case TT::plus:       returnStr(" + "); break;
    case TT::minus:      returnStr(" - "); break;
    case TT::mply:       returnStr(" * "); break;
    case TT::div:        returnStr(" / "); break;
    case TT::intDiv:     returnStr(" // "); break;
    case TT::mod:        returnStr(" % "); break;
    case TT::pow:        returnStr(" ** "); break;
    case TT::eq:         returnStr(" == "); break;
    case TT::ne:         returnStr(" != "); break;
    case TT::lt:         returnStr(" < "); break;
    case TT::gt:         returnStr(" > "); break;
    case TT::le:         returnStr(" <= "); break;
    case TT::ge:         returnStr(" >= "); break;
    case TT::and_:       returnStr(" && "); break;
    case TT::or_:        returnStr(" || "); break;
    case TT::not_:       returnStr("!"); break;
    case TT::xor_:       returnStr(" ^ "); break;
    case TT::bAnd:       returnStr(" & "); break;
    case TT::bOr:        returnStr(" | "); break;
    case TT::lsh:        returnStr(" << "); break;
    case TT::rsh:        returnStr(" >> "); break;
    case TT::tilde:      returnStr(" ~ "); break;
    case TT::assign:     returnStr(" = "); break;
    case TT::question:   returnStr("?"); break;
    case TT::colon:      returnStr(":"); break;
    case TT::catEq:      returnStr(" ~= "); break;
    case TT::plusEq:     returnStr(" += "); break;
    case TT::minusEq:    returnStr(" -= "); break;
    case TT::mplyEq:     returnStr(" *= "); break;
    case TT::divEq:      returnStr(" /= "); break;
    case TT::intDivEq:   returnStr(" //= "); break;
    case TT::modEq:      returnStr(" %= "); break;
    case TT::powEq:      returnStr(" **= "); break;
    case TT::lshEq:      returnStr(" <<= "); break;
    case TT::rshEq:      returnStr(" >>= "); break;
    case TT::andEq:      returnStr(" &= "); break;
    case TT::xorEq:      returnStr(" ^= "); break;
    case TT::orEq:       returnStr(" |= "); break;
    default:
        throw std::logic_error("INVALID");
        break;
        // clang-format on
        }*/
}
