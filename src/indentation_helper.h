#ifndef INDENTATION_HELPER_H
#define INDENTATION_HELPER_H
#include "editor.h"

struct IndentationHelper {
    typedef std::vector<int> Levels;
    typedef std::vector<std::vector<Token>> Data;
    typedef std::vector<Token>::const_iterator TokIter;
    Levels& levels;

    Levels::iterator lvlit;
    Data::const_iterator beginLine;
    Data::const_iterator line;
    const Data::const_iterator eof; //end of file
    int _lvl = 0;
    TokIter beginTok;
    TokIter tok;
    TokIter eol; //end of line

    IndentationHelper(Levels& levels)
        : levels(levels),
          beginLine(data().begin()),
          line(data().begin()),
          eof(data().end()),
          beginTok(line->begin()),
          tok(line->begin()),
          eol(line->end()) {
        levels.resize(data().size());
        lvlit = levels.begin();
        update();
    }
private:
    const Data& data() { return Editor::lines(); }
    void decLvl() {
        if (_lvl != 0)
            --_lvl;
    }
    void decLvlParen() {
        if (tok == beginTok) {
            if (line == beginLine)
                return;
            auto prev = lvlit - 1;
            if (*prev != 0)
                --(*prev);
        }
        if (_lvl != 0)
            --_lvl;
    }
    void incLvl() {
        ++_lvl;
    }

    bool isEof() { return line == eof; }
    bool isEol() { return tok == eol; }

    void nextLine() {
        if (isEof()) return;
        *lvlit = _lvl;
        //qDebug(">> %d", _lvl);
        ++line;
        ++lvlit;
        if (isEof()) return;

        beginTok = tok = line->begin();
        eol = line->end();
    }
    TT type() {
        if (isEof() || isEol()) return TT::eof;
        return tok->type;
    }
    void next() {
        if (isEol())
            nextLine();
        else
            ++tok;
    }
    bool is(TT tt) {
        if (type() == tt) return true;
        return false;
    }
    template <typename... Args>
    bool is(TT type, Args... args) {
        return is(type) || is(args...);
    }
    template <typename... Args>
    bool consume(TT type, Args... args) {
        if (is(type, args...)) {
            next();
            return true;
        }
        return false;
    }
    template <typename... Args>
    bool consume(TT* out, TT type, Args... args) {
        if (is(type, args...)) {
            *out = tok->type;
            next();
            return true;
        }
        return false;
    }


    void update() {
        while (!isEof()) {
            //unmatched parens
            if (consume(TT::rParen, TT::rSquare, TT::rCurly))
                continue;
            statement();
        }
    }
    void statement() {
        if (isEol()) nextLine();
        if (isEof()) return;
        TT tt;
        if (consume(&tt, TT::if_, TT::else_, TT::while_, TT::for_, TT::fun)) {
            //qDebug("if ++");
            incLvl();
            if (tt == TT::fun && consume(TT::identifier)) {
                parenthesis();
                parenthesis();
            }
            else if (tt != TT::else_) {
                parenthesis();
            }
            while (isEol()) {
                if (isEof()) return;
                nextLine();
            }
            statement();
            //qDebug("block --");
            decLvl();
        }
        else if (consume(TT::lCurly)) {
            //qDebug("{ ++ ");

            incLvl();
            while (!isEof()) {
                if (is(TT::rCurly)) {
                    //qDebug("} --");
                    decLvlParen();
                    next();
                    break;
                }
                statement();
            }
        }
        else if (is(TT::rCurly)) return;
        else {
            //qDebug("t++");
            if (!parenthesis()) next();
            if (is(TT::lCurly, TT::rCurly)) return;

            incLvl();
            while (!isEof()) {
                if (isEol()) {nextLine(); continue;}
                //qDebug() << "t:" << (isEol()? "EOL": tok->toString());
                if (consume(TT::terminator)||is(TT::lCurly, TT::rCurly)) break;
                if (!parenthesis()) next();
                /*
                else if (is(TT::lParen, TT::lSquare, TT::lCurly)) {
                    incLvl();
                }
                else if (is(TT::rParen, TT::rSquare, TT::rCurly))
                    decLvlParen();
                next();
                */
            }
            decLvlParen();
            //qDebug("t--");
        }
    }
    bool parenthesis() {
        int lvl = 0;
        if (!consume(TT::lParen, TT::lSquare)) return false;
        while (!isEof()) {
            if (is(TT::lCurly, TT::rCurly)) return false;
            if (is(TT::lParen, TT::lSquare /*,TT::lCurly*/)) {
                ++lvl;
                //qDebug("Paren++");
                incLvl();
            }
            else if (is(TT::rParen, TT::rSquare /*, TT::rCurly*/)) {
                --lvl;
                if (lvl <= 0) break;
                //qDebug("Paren--");
                decLvlParen();
            }
            next();
        }
        return true;
    }
};
#endif
