#include "editor_text_base.h"

#include "colors.h"
#include "config.h"

#include <QFontDatabase>
#include <QFontMetricsF>
#include <QPainter>


EditorTextBase::EditorTextBase(QQuickItem* parent, int fontSize)
    : QQuickPaintedItem(parent) {
    font = QFont(config::fontFamMono);

    font.setPointSize(fontSize);
    fsd = FontSizeData(font);

    setAcceptedMouseButtons(Qt::LeftButton);
}
// clang-format off
//constexpr QPoint EditorTextBase::cursor() const { return _cursor; }
void EditorTextBase::setActive(bool a) { isActive = a; }

/*
void EditorTextBase::cursorLeft()  { setCursor(_cursor.x() - 1, _cursor.y()); update(); }
void EditorTextBase::cursorRight() { setCursor(_cursor.x() + 1, _cursor.y()); update(); }
void EditorTextBase::cursorUp()    { setCursor(_cursor.x(), _cursor.y() - 1); update(); }
void EditorTextBase::cursorDown()  { setCursor(_cursor.x(), _cursor.y() - 1); update(); }
void EditorTextBase::setCursor(int x, int y) { setCursor(QPoint(x,y)); }
void EditorTextBase::setCursor(QPoint p) { _cursor = p; }
*/
//constexpr QPoint EditorTextBase::cursor() const { return _cursor; }

// clang-format on

void EditorTextBase::touchEvent(QTouchEvent* e) {
    if (!isActive) return;
    auto points = e->touchPoints();
    if (points.length() != 1) return;
    setCursorScreen(points[0].pos());
}
void EditorTextBase::mousePressEvent(QMouseEvent* e) {
    //if (e->button() != Qt::LeftButton) return;
    if (!isActive) return;
    setCursorScreen(e->pos());
}
/*
void EditorTextBase::setCursorScreen(QPointF p) {
    if (!isActive) return;
    p -= origin();
    setCursor(p.x() / fsd.width, p.y() / fsd.height);
    //qDebug() << "cs:" << p.x() / fsd.width <<"," <<p.y() / fsd.height;// _cursor.x() << "," << _cursor.y();

    update();
    }*/
void EditorTextBase::drawCursor(QPainter* p, int x, int y) const {
    auto o = origin();
    p->fillRect(fsd.width * x + o.x(), fsd.height * y + o.y(),
                fsd.width * config::cursorPerc, fsd.height, colors::cursor);
}

