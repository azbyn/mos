#include "number_text.h"
#include "colors.h"
#include "config.h"

#include <QPainter>


NumberText::NumberText(QQuickItem* parent)
    : EditorTextBase(parent, config::fontSizeNumber) {
}

void NumberText::addChar(const QString& s) {
    if (val.size() >= length() - 1) return;
    val.insert(cursor++, s);
    update();
}
void NumberText::del() {
    if (val.size() == 0 || cursor == 0) return;
    qDebug() << "sz:" << val.size();
    val.remove(--cursor, 1);
    update();
}
void NumberText::reset() {
    cursor = 0;
    val = "";
}

constexpr float percX = 0.8f;
constexpr int margin = 2, paddingX = 5, paddingY = 10;
QPoint NumberText::origin() const {
    //auto h = paddingY + fsd.height;
    return QPoint(width() * (1 - percX) / 2 + paddingX,
                  (height() - fsd.height) / 2 /*+ (paddingY / 2) + fsd.ascent*/);
}
int NumberText::length() const {
    return width() * percX / fsd.width;
}

/*void NumberText::setCursorScreen(QPointF p) {
    if (!isActive) return;
    p -= origin();
    
    auto t = p.y() / fsd.height;
    qDebug() << "cs:" << p.x() << "," << t;
    if (t >= 1 || t < 0) return;
    cursor.rx() = (int)(p.x() / fsd.width);

    update();
    }*/

void NumberText::paint(QPainter* p) {
    auto c = colors::background;
    c.setAlpha(128);
    p->fillRect(0, 0, width(), height(), c);
    auto h = paddingY + fsd.height;

    QRect r(origin().x() - paddingX, (height() - h) / 2 /* - fsd.ascent*/,
            width() * percX,
            paddingY + fsd.height);
    p->fillRect(QRect(r.x() - margin, r.y() - margin,
                      r.width() + 2 * margin, r.height() + 2 * margin),
                colors::base03);
    p->fillRect(r, colors::base00);
    auto point = QPoint(r.x() + paddingX, r.y() + (paddingY / 2) + fsd.ascent);

    p->setFont(font);
    //auto point = fillRectCenter(this, p, 0.8f, 0.5f, colors::base00, 5, colors::base03);
    p->setPen(colors::defaults);
    p->drawText(point, val);
    drawCursor(p, cursor, 0);
}
void NumberText::cursorLeft() {
    if (cursor == 0) return;
    --cursor;
    update();
}
void NumberText::cursorRight() {
    if (cursor > length() - 1) return;
    ++cursor;
    update();
}
void NumberText::setCursor(int c) {
    auto len = val.length();
    cursor = c > len ? len : c;
}

void NumberText::setCursorScreen(QPointF p) {
    p -= origin();
    auto x = p.x() / fsd.width;
    auto y = p.y() / fsd.height;
    if ((int)y != 0 || x >= length()) return;
    qDebug() << "scs:" << x << "," << y;
    setCursor((int)x);

    update();
}
