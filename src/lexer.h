#ifndef LEXER_H
#define LEXER_H

#include "ts/ast/token.h"

#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <vector>

struct Lexer {
    std::vector<std::vector<Token>>* out;
    std::vector<Token>* line;
    QFile file;
    Lexer(std::vector<std::vector<Token>>* out, const QString& path) : out(out), file(path) {
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << "invalid path :" << path;
            return;
        }
        qDebug() << "reading " << path;
    }
    QString str;
    void lex() {
        QTextStream in(&file);

        out->clear();
        out->emplace_back();
        line = &out->back();
        while (!in.atEnd()) {
            str = in.readLine();
            //qDebug() << "<<" << str;
            if (regexIgnore("^\\s*#")) continue;
            while (str.size()) {
                //qDebug() << "sz= " << str.size() << str;
                if (regexIgnore("^\\s+")) continue;

                if (str[0] == '#') {
                    break;
                }
                //if (regexIgnore("#.*$")) continue;
                if (pat(";", TT::terminator)) continue;
                if (pat(",", TT::comma)) continue;
                if (pat(".", TT::dot)) continue;
                if (regex("^0[xbo][0-9A-Fa-f]+", TT::number)) continue;
                if (regex("^[0-9]*\\.[0-9]+", TT::number)) continue;
                if (regex("^[0-9]+", TT::number)) continue;
                if (regex("^[_a-zA-Z][_a-zA-Z0-9]*", 0, [](const QString& str) {
                        if (str == "return") return Token(TT::return_);
                        if (str == "fun") return Token(TT::fun);
                        if (str == "if") return Token(TT::if_);
                        if (str == "else") return Token(TT::else_);
                        if (str == "continue") return Token(TT::continue_);
                        if (str == "break") return Token(TT::break_);
                        if (str == "while") return Token(TT::while_);
                        if (str == "for") return Token(TT::for_);
                        if (str == "in") return Token(TT::in);
                        if (str == "true") return Token(TT::true_);
                        if (str == "false") return Token(TT::false_);
                        return Token(TT::identifier, str);
                    })) continue;
                if (regex("\"(.*?)\"", 1, TT::string)) continue;
                if (pat("~=", TT::catEq)) continue;
                if (pat("+=", TT::plusEq)) continue;
                if (pat("-=", TT::minusEq)) continue;
                if (pat("*=", TT::mplyEq)) continue;
                if (pat("/=", TT::divEq)) continue;
                if (pat("//=", TT::intDivEq)) continue;
                if (pat("%=", TT::modEq)) continue;
                if (pat("**=", TT::powEq)) continue;
                if (pat("<<=", TT::lshEq)) continue;
                if (pat(">>=", TT::rshEq)) continue;
                if (pat("&=", TT::andEq)) continue;
                if (pat("^=", TT::xorEq)) continue;
                if (pat("|=", TT::orEq)) continue;
                if (pat("\\", TT::lambda)) continue;
                if (pat("->", TT::arrow)) continue;
                if (pat("(", TT::lParen)) continue;
                if (pat(")", TT::rParen)) continue;
                if (pat("[", TT::lSquare)) continue;
                if (pat("]", TT::rSquare)) continue;
                if (pat("{", TT::lCurly)) continue;
                if (pat("}", TT::rCurly)) continue;

                if (pat("++", TT::inc)) continue;
                if (pat("--", TT::dec)) continue;
                if (pat("+", TT::plus)) continue;
                if (pat("-", TT::minus)) continue;
                if (pat("**", TT::pow)) continue;
                if (pat("*", TT::mply)) continue;
                if (pat("//", TT::intDiv)) continue;
                if (pat("/", TT::div)) continue;
                if (pat("%", TT::mod)) continue;
                if (pat("<<", TT::lsh)) continue;
                if (pat(">>", TT::rsh)) continue;
                if (pat("==", TT::eq)) continue;
                if (pat("!=", TT::ne)) continue;
                if (pat("<=", TT::le)) continue;
                if (pat(">=", TT::ge)) continue;
                if (pat("<", TT::lt)) continue;
                if (pat(">", TT::gt)) continue;
                if (pat("&&", TT::and_)) continue;
                if (pat("||", TT::or_)) continue;
                if (pat("!", TT::not_)) continue;
                if (pat("^", TT::xor_)) continue;
                if (pat("&", TT::bAnd)) continue;
                if (pat("|", TT::bOr)) continue;
                if (pat("~", TT::tilde)) continue;
                if (pat("=", TT::assign)) continue;
                if (pat("?", TT::question)) continue;
                if (pat(":", TT::colon)) continue;
                Q_ASSERT_X(0, "lex", "invalid char"); // format!"invalid char '%s'"(str[0]));
            }
            out->emplace_back();
            line = &out->back();
        }
    }

private:
    bool pat(const QString& ptrn, TT tt) {
        if (!str.startsWith(ptrn))
            return false;
        line->emplace_back(tt /*, in->left(ptrn.size())*/);
        str.remove(0, ptrn.size());
        return true;
    }
    bool regex(const QString& ptrnStr, TT tt) {
        return regex(ptrnStr, 0, tt);
    }
    bool regex(const QString& ptrnStr, int cap, TT tt) {
        Q_ASSERT(ptrnStr[0] == '^');
        QRegExp ptrn(ptrnStr);
        int pos = ptrn.indexIn(str);
        if (pos < 0) return false;
        auto val = ptrn.cap(cap);
        line->emplace_back(tt, val);
        str.remove(0, ptrn.cap(0).size());
        return true;
    }
    template <typename F>
    bool regex(const QString& ptrnStr, int cap, F f) {
        Q_ASSERT(ptrnStr[0] == '^');
        QRegExp ptrn(ptrnStr);

        int pos = ptrn.indexIn(str);
        if (pos < 0)
            return false;
        auto val = ptrn.cap(cap);
        line->push_back(f(val));
        str.remove(0, ptrn.cap(0).size());
        return true;
    }

    bool regexIgnore(const QString& ptrnStr) {
        Q_ASSERT(ptrnStr[0] == '^');

        QRegExp ptrn(ptrnStr);
        int pos = ptrn.indexIn(str);
        if (pos < 0)
            return false;
        str.remove(0, ptrn.cap(0).size());
        return true;
    }
};

inline void lex(std::vector<std::vector<Token>>* out, const QString& path) {
    Lexer l(out, path);
    l.lex();
}
#endif
