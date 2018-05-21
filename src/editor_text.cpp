#include "editor_text.h"

#include "colors.h"
#include "config.h"
#include "lexer.h"
#include "misc.h"

#include <scope_guard.h>
#include <QPainter>

/*
#include <QColor>
#include <QFontDatabase>
#include <QFontMetricsF>
#include <QKeyEvent>
#include <QLoggingCategory>
#include <QMouseEvent>
#include <QTouchEvent>
*/
EditorText* EditorText::instance = nullptr;

EditorText::EditorText(QQuickItem* parent)
    : EditorTextBase(parent, config::fontSize),
      data{
          {tok_identifier("print"), tok_lParen(), tok_string("hello world"), tok_rParen(), tok_terminator()},
          {tok_identifier("foo"), tok_assign(), tok_number("42"), tok_terminator()},
          {tok_if(), tok_lParen(), tok_identifier("foo"), tok_rParen(), tok_lCurly()},
          {tok_identifier("print"), tok_lParen(), tok_identifier("foo"), tok_rParen(), tok_terminator()},
          {tok_rCurly()},
      } {
    bold = font;
    bold.setBold(true);
    if (instance != nullptr) throw "EXPECTED ONE INSTANCE OF EditorText";
    instance = this;
#ifndef ANDROID
    lex(&data, config::file);
#endif
    updateLevels();
}
void EditorText::addToken(TT type, const QString& msg) {
    auto& v = data[cursor.y()];
    qDebug("AddToken(%d)", (int)type);
    v.emplace(v.begin() + cursor.x(), Token(type, msg));
    ++cursor.rx();
    update();
    updateLevels();
}

void EditorText::cursorLeft() {
    if (cursor.x() == 0) {
        if (cursor.y() == 0) return;
        auto v = data[--cursor.ry()];
        cursor.rx() = v.size();
    }
    else {
        --cursor.rx();
    }
    update();
}
void EditorText::cursorRight() {
    auto& v = data[cursor.y()];
    if ((size_t)cursor.x() == v.size()) {
        if ((size_t)cursor.y() == data.size() - 1) return;
        ++cursor.ry();
        cursor.rx() = 0;
    }
    else {
        ++cursor.rx();
    }
    update();
}

void EditorText::del() {
    if (cursor.x() == 0) {
        if (cursor.y() == 0) return;
        auto old = data.begin() + cursor.y();
        auto& now = data[--cursor.ry()];
        cursor.rx() = now.size();
        now.insert(now.end(), old->begin(), old->end());
        data.erase(old);
    }
    else {
        auto& v = data[cursor.y()];
        --cursor.rx();
        v.erase(v.begin() + cursor.x());
    }
    update();
}
void EditorText::add_newLine() {
    if (cursor.x() == 0) {
        data.insert(data.begin() + cursor.y(), std::vector<Token>());
    }
    else {
        auto it = data.begin() + cursor.y();
        if (cursor.x() == (int)it->size()) {
            data.insert(it + 1, std::vector<Token>());
        }
        else {
            data.insert(it + 1, std::vector<Token>(it->begin() + cursor.x(), it->end()));
            auto& v = data[cursor.y()];
            v = std::vector<Token>(v.begin(), v.begin() + cursor.x());
        }
        cursor.rx() = 0;
    }
    ++cursor.ry();
    update();
    updateLevels();
}
void EditorText::setCursorScreen(QPointF p) {
    p -= origin();
    SCOPE_EXIT({ update(); });
    size_t line = p.y() / fsd.height;
    if (p.y() < 0) {
        //qDebug("setcurs 0,0");
        cursor = QPoint(0, 0);
    }
    else if (line >= data.size()) {
        //qDebug("setcurs data.size()");
        cursor.ry() = data.size() == 0 ? 0 : (data.size() - 1);
        cursor.rx() = data[cursor.y()].size();
        return;
    }

    auto& vec = data[line];
    auto col = (p.x() / fsd.width) - (levels[line] * config::indentSize);
    cursor.ry() = line;
    if (col <= 0) {
        //qDebug("setcurs %ld, 0", line);
        cursor.rx() = 0;
        return;
    }

    int prev = 0;
    int curr = 0;
    int i = 0;

    for (auto& t : vec) {
        prev = curr;
        curr += t.toString().size();
        if (col > curr) {
            ++i;
            continue;
        }
        auto mid = (curr + prev) * 0.5f;
        cursor.rx() = i + (col >= mid ? 1 : 0);
        if (cursor.x() < 0) cursor.rx() = 0;
        //qDebug("setcurs %ld, %d %lf: (%d, %d)", line, i, col, prev, curr);
        return;
    }
    cursor.rx() = vec.size();
    //qDebug("setcurs %ld, $ (%d)", line, cursor.x());
}

QPoint EditorText::origin() const {
    if (config::hasLineNumbers)
        return QPoint(4 + fsd.width * (0.5f + digits(data.size())), 0);
    return QPoint(2, 0);
}

typedef std::vector<int> Levels;
typedef std::vector<std::vector<Token>> Data;
typedef std::vector<Token>::const_iterator TokIter;
//indentaion levels:
struct IndentationHelper {
    Levels& levels;
    const EditorText* et;

    Levels::iterator lvlit;
    Data::const_iterator beginLine;
    Data::const_iterator line;
    const Data::const_iterator eof; //end of file
    int _lvl = 0;
    TokIter beginTok;
    TokIter tok;
    TokIter eol; //end of line

    IndentationHelper(Levels& levels, const EditorText* et)
        : levels(levels), et(et),
          beginLine(data().begin()),
          line(data().begin()),
          eof(data().end()),
          beginTok(line->begin()),
          tok(line->begin()),
          eol(line->end()) {
        levels.resize(data().size());
        lvlit = levels.begin();
    }
    /*
  void decLevel() {
  --_level;
  }
  void incLevel() {
  ++_level;
  if (iter == beginTok) vCursor.rx() += config::indentSize;

  }
 */
    void decLvl() {
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

    const Data& data() { return et->data; }
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

    void update() {
        while (!isEof()) {
            statement();
        }
    }
    void statement() {
        if (isEol()) nextLine();
        if (isEof()) return;
        if (is(TT::if_, TT::else_, TT::while_, TT::for_, TT::fun)) {
            bool wasFun = is(TT::fun);
            next();

            incLvl();
            if (wasFun && consume(TT::identifier)) {
                parenthesis();
                parenthesis();
            }
            else {
                parenthesis();
            }
            if (consume(TT::lCurly)) {
                while (!isEof()) {
                    if (isEol()) {
                        nextLine();
                        continue;
                    }
                    if (is(TT::rCurly)) {
                        decLvl();
                        next();
                        break;
                    }
                    statement();
                }
            }
            else {
                while (isEol())
                    nextLine();
                statement();
                decLvl();
            }
        }
        else {
            if (is(TT::lParen, TT::lSquare, TT::lCurly))
                incLvl();
            else if (is(TT::rParen, TT::rSquare, TT::rCurly))
                decLvl();
            next();
        }
    }
    void parenthesis() {
        int lvl = 0;
        while (!isEof()) {
            if (is(TT::lCurly)) break;
            if (is(TT::lParen, TT::lSquare /*,TT::lCurly*/))
                ++lvl;
            else if (is(TT::rParen, TT::rSquare /*, TT::rCurly*/))
                --lvl;
            next();
            if (lvl <= 0) break;
        }
    }
};
void EditorText::updateLevels() {
    IndentationHelper ih(levels, this);
    ih.update();
}

void EditorText::paint(QPainter* const p) {
    QPoint vCursor(0, 0);
    int lineNum = 0;
    int tokNum = 0;
    const auto lineCount = data.size();
    const auto origin = this->origin();
    const auto width = this->width();
    const auto height = this->height();

    auto checkCursor = [this, p, &vCursor, &lineNum, &tokNum] {
        if (lineNum != cursor.y() || tokNum != cursor.x()) return;
        drawCursor(p, vCursor.x(), vCursor.y());
    };
    auto drawLineNumber = [this, lineCount, p, &lineNum] {
        if (!config::hasLineNumbers) return;
        auto num = lineNum; // levels[lineNum]; //lineNum;
        if (num == cursor.y()) {
            p->setPen(colors::base05);
            p->setFont(bold);
        }
        else {
            p->setPen(colors::base03);
            p->setFont(font);
        }
        auto txt = QString::number(num + 1);
        auto padding = 2 + (digits(lineCount) - txt.size()) * fsd.width;
        p->drawText(padding, fsd.ascent + fsd.height * num, txt);
        p->setFont(font);
    };
    //draw zone where line numbers are
    p->fillRect(0, 0, width, height, colors::background);
    if (config::hasLineNumbers) {
        p->fillRect(0, 0, origin.x() - 2, height, colors::base01);
    }
    for (auto line = data.begin(), eof = data.end(); line != eof; ++line, ++lineNum) {
        drawLineNumber();
        tokNum = 0;
        for (auto tok = line->begin(), eol = line->end(); tok != eol; ++tok, ++tokNum) {
            auto prevTT = [tokNum, &tok] {
                if (tokNum == 0) {
                    // we could do recursion but it's overkill
                    // as prevTT is only used for `fun foo` and
                    // that's not usualy on different lines
                    return TT::eof;
                }
                return (tok - 1)->type;
            };
            auto nextTT = [&tok, &eol, &line, &eof] {
                auto next = tok + 1;
                if (next == eol) {
                    auto nextLine = line + 1;
                    if (nextLine != eof) {
                        if (nextLine->size() != 0)
                            return nextLine->front().type;
                    }
                }
                else {
                    if (next < eol)
                        return next->type;
                }
                return TT::eof;
            };
            checkCursor();
            p->setPen(tok->color(prevTT, nextTT));
            auto str = tok->toString();
            p->drawText(vCursor.x() * fsd.width + origin.x(),
                        fsd.ascent + fsd.height * vCursor.y(),
                        str);
            vCursor.rx() += str.size();
        }
        checkCursor();
        vCursor.rx() = levels[lineNum] * config::indentSize;
        ++vCursor.ry();
    }
}
