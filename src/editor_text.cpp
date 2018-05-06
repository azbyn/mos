#include "editor_text.h"

#include "colors.h"
#include "config.h"

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

EditorText::EditorText(QQuickItem* parent)
    : EditorTextBase(parent, config::fontSize), tokens{
    tok_identifier("print"), tok_lParen(), tok_string("hi"), tok_newLine(), tok_rParen(), tok_terminator()} {}

void EditorText::addToken(TT type, const QString& msg) {
    tokens.emplace_back(Token(type, msg));
}
void EditorText::addToken(TT type, QString&& msg) {
    tokens.emplace_back(Token(type, msg));
}

void EditorText::cursorLeft()  {
    if (cursor == 0) return;
    --cursor;
    update();
}
void EditorText::cursorRight() {
    if ((uint)cursor >= tokens.size()) return;
    ++cursor;
    update();
}


QPoint EditorText::origin() const { return QPoint(2, 0); }
void EditorText::paint(QPainter* p) {
    p->setFont(font);
    p->setPen(colors::defaults);
    p->fillRect(0, 0, width(), height(), colors::background);
    p->translate(origin());

    QPoint c(0,0);
    int i = 0;
    constexpr auto getNext = [](auto start, auto end) {
        ++start;
        for (auto it = start; it != end; ++it) {
            if (it->type != TT::newLine) return it->type;
        }
        return TT::eof;
    };

    for (auto it = tokens.begin(), end = tokens.end(); it != end; ++it) {
        if (i++ == cursor) drawCursor(p, c.x(), c.y());
        if (it->type == TT::newLine) {
            c.rx() = 0;
            ++c.ry();
            continue;
        }
        p->setPen(it->color(getNext(it, end)));
        auto str = it->toString();
        p->drawText(c.x() * fsd.width, fsd.ascent + fsd.height * c.y(), str);
        c.rx() += str.size();
    }
    if (i == cursor) drawCursor(p, c.x(), c.y());
}
