#include "editor_text.h"

#include "colors.h"
#include "config.h"
#include "misc.h"

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
          {tok_identifier("print"), tok_lParen(), tok_string("hi"), tok_rParen(), tok_terminator()},
          {tok_identifier("print"), tok_lParen(), tok_identifier("foo"), tok_rParen(), tok_terminator()},
      } {
    bold = font;
    bold.setBold(true);
    if (instance != nullptr) throw "EXPECTED ONE INSTANCE OF EditorText";
    instance = this;
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
    data.insert(data.begin() + cursor.y(), {});
    ++cursor.ry();
}

QPoint EditorText::origin() const {
    if (config::hasLineNumbers)
        return QPoint(4 + fsd.width * (0.5f + digits(data.size())), 0);
    return QPoint(2, 0);
}
void EditorText::paint(QPainter* p) {
    auto origin = this->origin();
    auto lineCount = (int)data.size();

    p->setPen(colors::defaults);
    p->fillRect(0, 0, width(), height(), colors::background);
    if (config::hasLineNumbers) {
        p->fillRect(0, 0, origin.x() - 2, height(), colors::base01);
    }
    //p->translate(origin);

    for (int vLine = 0; vLine < lineCount; ++vLine) {
        auto& v = data[vLine];
        int tokNo = 0;
        int vColumn = 0;
        if (config::hasLineNumbers) {
            auto isCurr = vLine == cursor.y();
            p->setPen(isCurr ? colors::base05 : colors::base03);
            p->setFont(isCurr ? bold : font);
            auto txt = QString::number(vLine + 1);
            auto padding = 2 + (digits(data.size()) - txt.size()) * fsd.width;
            p->drawText(padding, fsd.ascent + fsd.height * vLine, txt);
        }
        p->setFont(font);

        for (auto it = v.begin(), end = v.end(); it != end; ++it) {
            TT nextTT = [&] {
                auto next = it + 1;
                if (next == end) {
                    if (vLine < lineCount - 1) {
                        auto& v = data[vLine + 1];
                        if (v.size() != 0) return v[0].type;
                    }
                }
                else {
                    return next->type;
                }
                return TT::eof;
            }();
            p->setPen(it->color(nextTT));
            auto str = it->toString();
            p->drawText(vColumn * fsd.width + origin.x(), fsd.ascent + fsd.height * vLine, str);
            if (vLine == cursor.y() && tokNo++ == cursor.x()) drawCursor(p, vColumn, vLine);
            vColumn += str.size();
        }
        if (vLine == cursor.y() && tokNo == cursor.x()) drawCursor(p, vColumn, vLine);
    }
}
