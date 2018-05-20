#include "editor_text.h"

#include "colors.h"
#include "config.h"
#include "misc.h"
#include "lexer.h"

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
          {tok_if(), tok_lParen(), tok_identifier("foo"), tok_rParen(), tok_lCurly() },
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
}

void EditorText::addToken(TT type, const QString& msg) {
    auto& v = data[cursor.y()];
    v.emplace(v.begin() + cursor.x(), Token(type, msg));
    ++cursor.rx();
    update();
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
}
void EditorText::setCursorScreen(QPointF p) {
    p -= origin();
    SCOPE_EXIT({ update(); });
    auto line = p.y() / fsd.height;
    if (line >= data.size()) {
        qDebug("setcurs data.size()");
        cursor.ry() = data.size() == 0 ? 0 : (data.size() - 1);
        cursor.rx() = data[cursor.y()].size();
        return;
    }
    else if (line < 0) {
        qDebug("setcurs 0,0");
        cursor = QPoint(0, 0);
    }
    auto& vec = data[line];
    auto col = p.x() / fsd.width;
    int prev = 0;
    int curr = 0;
    int i = 0;

    cursor.ry() = line;
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
        qDebug("setcurs %lf, %d %lf: (%d, %d)", line, i, col, prev, curr);
        return;
    }
    cursor.rx() = vec.size();
    qDebug("setcurs %lf, $ (%d)", line, cursor.x());
}

QPoint EditorText::origin() const {
    if (config::hasLineNumbers)
        return QPoint(4 + fsd.width * (0.5f + digits(data.size())), 0);
    return QPoint(2, 0);
}

//drawing stuff
struct PaintHelper {
    QPainter* p;
    const EditorText* et;
    const QPoint origin;
    const int lineCount;
    const qreal width, height;
    typedef std::vector<std::vector<Token>> Data;
    typedef std::vector<Token>::const_iterator TokIter;
    Data::const_iterator beginLine;
    Data::const_iterator line;
    const Data::const_iterator eof; //end of file
    int _level = 0;
    TokIter beginTok;
    TokIter iter;
    TokIter eol; //end of line

    QPoint vCursor = QPoint(0, 0); //visual cursor
    constexpr const Data& data() { return et->data; }
    constexpr const FontSizeData& fsd() { return et->fsd; }
    constexpr const QPoint& cursor() { return et->cursor; }
    constexpr const QFont& bold() { return et->bold; }
    constexpr const QFont& font() { return et->font; }

    PaintHelper(QPainter* p, const EditorText* et)
        : p(p), et(et),
          origin(et->origin()),
          lineCount(et->data.size()),
          width(et->width()),
          height(et->height()),
          beginLine(data().begin()),
          line(data().begin()),
          eof(data().end()),
          beginTok(line->begin()),
          iter(line->begin()),
          eol(line->end()) {
    }

    void decLevel() {
        --_level;
        if (iter == beginTok) vCursor.rx() -= config::indentSize;
    }
    void incLevel() {
        ++_level;
        if (iter == beginTok) vCursor.rx() += config::indentSize;

    }


    int lineNumber() { return line - beginLine; }
    int tokNum() { return iter - beginTok; }
    bool isEof() { return line == eof; }
    bool isEol() { return iter == eol; }
    void nextLine() {
        if (isEof()) return;
        if (lineNumber() == cursor().y() && tokNum() == cursor().x())
            drawCursor();
        ++line;
        if (isEof()) return;

        beginTok = iter = line->begin();
        eol = line->end();

        vCursor.rx() = _level * config::indentSize;
        ++vCursor.ry();
        drawLineNumber();
    }
    TT type() {
        if (isEof() || isEol()) return TT::eof;
        return iter->type;
    }
    void next() {
        if (isEol())
            nextLine();
        else
            ++iter;
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
    TT nextTT() {
        auto next = iter + 1;
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
    }
    TT prevTT() {
        if (iter == beginTok){
            // we could do recursion but it's overkill
            // as prevTT is only used for `fun foo` and
            // that's not usualy on different lines
            return TT::eof;
        }
        return (iter-1)->type;
    }
    void drawCursor() {
        p->fillRect(fsd().width * vCursor.x() + origin.x(),
                    fsd().height * vCursor.y() + origin.y(),
                    fsd().width * config::cursorPerc,
                    fsd().height,
                    colors::cursor);
    }
    void drawTok() {
        if (isEol()) return;
        if (lineNumber() == cursor().y() && tokNum() == cursor().x())
            drawCursor();
        p->setPen(iter->color(
                      [this] { return prevTT(); },
                      [this] { return nextTT(); }));
        auto str = iter->toString();
        p->drawText(vCursor.x() * fsd().width + origin.x(),
                    fsd().ascent + fsd().height * vCursor.y(),
                    str);
        vCursor.rx() += str.size();
    }
    void drawLineNumber() {
        if (!config::hasLineNumbers) return;
        auto num = lineNumber();
        if (num == cursor().y()) {
            p->setPen(colors::base05);
            p->setFont(bold());
        }
        else {
            p->setPen(colors::base03);
            p->setFont(font());
        }
        //auto isCurr = num == cursor().y();
        //p->setPen(isCurr ? colors::base05 : colors::base03);
        //p->setFont(isCurr ? bold() : font());
        auto txt = QString::number(num + 1);
        auto padding = 2 + (digits(lineCount) - txt.size()) * fsd().width;
        p->drawText(padding, fsd().ascent + fsd().height * num, txt);
        p->setFont(font());
    }

    void draw() {
        //draw zone where line numbers are
        p->fillRect(0, 0, width, height, colors::background);
        if (config::hasLineNumbers) {
            p->fillRect(0, 0, origin.x() - 2, height, colors::base01);
        }
        drawLineNumber();

        while (!isEof()) {
            statement();
        }
    }
    void statement() {
        if (isEol()) nextLine();
        if (isEof()) return;
        drawTok();
        if (is(TT::if_, TT::else_, TT::while_, TT::for_, TT::fun)) {
            bool wasFun = is(TT::fun);
            next();
            incLevel();
            parenthesis();
            if (wasFun) parenthesis();
            if (is(TT::lCurly)) {
                ++vCursor.rx();
                drawTok();
                next();
                while (!isEof()) {
                    if (isEol()) {
                        nextLine();
                        continue;
                    }
                    if (is(TT::rCurly)) {
                        decLevel();
                        drawTok();
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
                decLevel();
            }
        }
        else {
            if (consume(TT::lParen, TT::lSquare, TT::lCurly)) incLevel();
            else if (consume(TT::rParen, TT::rSquare, TT::rCurly)) decLevel();
            else next();
        }
    }
    void parenthesis() {
        int lvl = 0;
        while (!isEof()) {
            if (is(TT::lCurly)) break;
            drawTok();
            if (consume(TT::lParen, TT::lSquare/*,TT::lCurly*/)) ++lvl;
            else if (consume(TT::rParen, TT::rSquare/*, TT::rCurly*/)) --lvl;
            else next();
            if (lvl <= 0) break;
        }
    }
};

void EditorText::paint(QPainter* p) {
    PaintHelper helper(p, this);
    helper.draw();
}
