#ifndef LEXER_H
#define LEXER_H

#include "ts/ast/token.h"

#include <QDebug>
#include <QFile>
#include <QTextStream>
#include <vector>
#include <exception>

struct Lexer {
    std::vector<std::vector<Token>>* out;
    std::vector<Token>* line;
    QFile file;
    QString str;
    Lexer(std::vector<std::vector<Token>>* out,
          std::vector<int>* levels,
          const QString& path) : out(out), file(path) {
        if (!file.open(QIODevice::ReadOnly | QIODevice::Text)) {
            qWarning() << "invalid path :" << path;
            return;
        }

        qDebug() << "reading " << path;
        QTextStream in(&file);

        //out->clear();
        out->emplace_back();
        line = &out->back();
        levels->push_back(0);
        while (!in.atEnd()) {
            str = in.readLine();
            if (regexIgnore("^\\s*#")) continue;
            if (regexIgnore("^\\s*$")) continue;
            int lvl = 0;
            while(str[0] == '\t') {
                ++lvl;
                str.remove(0, 1);
            }
            levels->push_back(lvl);
        end:
            while (str.size()) {
                if (str.startsWith("<<<")) {
                    str.remove(0, 3);
                    while (!in.atEnd()) {
                        int cnt = 0;
                        while(str.size()) {
                            if (str[0] == '>') ++cnt;
                            else cnt = 0;

                            str.remove(0, 1);
                            if (cnt == 3) {
                                goto end;
                            }
                        }
                        str = in.readLine();
                    }
                    qCritical() << "expected >>> found EOF";
                    throw std::runtime_error("expected >>> found EOF");
                }
                //qDebug() << "<<" << str;
                if (regexIgnore("^\\s+")) continue;
                if (str[0] == '#') break;
                if (str[0] == ';') {
                    str.remove(0, 1);
                    continue;
                }
                if (pat(",", TT::Comma)) continue;
                if (pat("...", TT::Variadic)) continue;
                if (pat(".", TT::Dot)) continue;
                if (regex("^0[xbo][0-9A-Fa-f]+", TT::Number)) continue;
                if (regex("^[0-9]*\\.[0-9]+", TT::Number)) continue;
                if (regex("^[0-9]+", TT::Number)) continue;
                if (regex("^[_a-zA-Z][_a-zA-Z0-9]*", 0, [](const QString& str) {
                        if (str == "return") return Token(TT::Return);
                        if (str == "this") return Token(TT::This);
                        if (str == "struct") return Token(TT::Struct);
                        if (str == "module") return Token(TT::Module);
                        if (str == "import") return Token(TT::Import);
                        if (str == "fun") return Token(TT::Fun);
                        if (str == "prop") return Token(TT::Prop);
                        if (str == "if") return Token(TT::If);
                        if (str == "elif") return Token(TT::Elif);
                        if (str == "else") return Token(TT::Else);
                        if (str == "continue") return Token(TT::Continue);
                        if (str == "break") return Token(TT::Break);
                        if (str == "while") return Token(TT::While);
                        if (str == "for") return Token(TT::For);
                        if (str == "in") return Token(TT::In);
                        if (str == "true") return Token(TT::True);
                        if (str == "false") return Token(TT::False);
                        return Token(TT::Identifier, str);
                    })) continue;
                if (regex("^\"([^\"]*)\"", 1, TT::String)) continue;
                if (pat("~=", TT::CatEq)) continue;
                if (pat("+=", TT::PlusEq)) continue;
                if (pat("-=", TT::MinusEq)) continue;
                if (pat("*=", TT::MplyEq)) continue;
                if (pat("/=", TT::DivEq)) continue;
                if (pat("//=", TT::IntDivEq)) continue;
                if (pat("%=", TT::ModEq)) continue;
                if (pat("**=", TT::PowEq)) continue;
                if (pat("<<=", TT::LshEq)) continue;
                if (pat(">>=", TT::RshEq)) continue;
                if (pat("&=", TT::AndEq)) continue;
                if (pat("^=", TT::XorEq)) continue;
                if (pat("|=", TT::OrEq)) continue;
                if (pat("\\", TT::Lambda)) continue;
                if (pat("->", TT::Arrow)) continue;
                if (pat("(", TT::LParen)) continue;
                if (pat(")", TT::RParen)) continue;
                if (pat("[", TT::LSquare)) continue;
                if (pat("]", TT::RSquare)) continue;
                if (pat("{", TT::LCurly)) continue;
                if (pat("}", TT::RCurly)) continue;

                if (pat("++", TT::Inc)) continue;
                if (pat("--", TT::Dec)) continue;
                if (pat("+", TT::Plus)) continue;
                if (pat("-", TT::Minus)) continue;
                if (pat("**", TT::Pow)) continue;
                if (pat("*", TT::Mply)) continue;
                if (pat("//", TT::IntDiv)) continue;
                if (pat("/", TT::Div)) continue;
                if (pat("%", TT::Mod)) continue;
                if (pat("<<", TT::Lsh)) continue;
                if (pat(">>", TT::Rsh)) continue;
                if (pat("==", TT::Eq)) continue;
                if (pat("!=", TT::Ne)) continue;
                if (pat("<=", TT::Le)) continue;
                if (pat(">=", TT::Ge)) continue;
                if (pat("<", TT::Lt)) continue;
                if (pat(">", TT::Gt)) continue;
                if (pat("&&", TT::And)) continue;
                if (pat("||", TT::Or)) continue;
                if (pat("!", TT::Not)) continue;
                if (pat("^", TT::Xor)) continue;
                if (pat("&", TT::BAnd)) continue;
                if (pat("|", TT::BOr)) continue;
                if (pat("~", TT::Tilde)) continue;
                if (pat("=", TT::Assign)) continue;
                if (pat("?", TT::Question)) continue;
                if (pat(":", TT::Colon)) continue;
                qCritical() << "invalid char" << str[0];
                throw std::runtime_error("invalid char");
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
        //qDebug("pos : %d", pos +1 == ptrn.cap(0).size());
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
        //qDebug("pos : %d", pos +1 == ptrn.cap(0).size());
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
        //qDebug("pos : %d", pos +1 == ptrn.cap(0).size());
        str.remove(0, ptrn.cap(0).size());
        return true;
    }
};
#endif
