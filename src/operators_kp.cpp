#include "operators_kp.h"

#include "colors.h"
#include "config.h"

#include <QFontDatabase>
#include <QPainter>
#include <QtMath>
#include <algorithm>

OperatorsKp::OperatorsKp(QQuickItem* parent)
    : QQuickPaintedItem(parent) {
    //int id = QFontDatabase::addApplicationFont(config::fontPath);
    //QString family = QFontDatabase::applicationFontFamilies(id).at(0);
    font = QFont(/*family*/);

    font.setPointSize(fontSize);
    fsd = FontSizeData(font);

    setAcceptedMouseButtons(Qt::LeftButton);
}

void OperatorsKp::setState(State s){
    state = s;
    update();
}
void OperatorsKp::paint(QPainter* p) {
    QPen pen(colors::Base01);
    pen.setWidth(2);
    p->setPen(pen);
    p->setFont(font);

    p->setBrush(colors::Base05);
    p->translate(width() / 2, height() / 2);
    r1 = height() / 2;
    r2 = r1 / 3;
    auto margins = pen.width() + 1;
    r1 -= margins;
    p->drawEllipse(-r1, -r1, r1 * 2, r1 * 2);
    auto size = currStateData().size();
    for (size_t i = 0; i < size; ++i) {
        auto txtA = -M_PI_2 + M_PI * 2 / size * i;
        auto a = -M_PI_2 + M_PI * 2 / size * (i + 0.5);
        QPointF vec(qCos(a), qSin(a));
        QPointF txtVec(qCos(txtA), qSin(txtA));
        QPointF txtPos = txtVec * r1 * 0.875;
        QString txt = currStateData()[i].name;
        txtPos.ry() -= fsd.xHeight * (txtVec.y() - 1) / 2;
        txtPos.rx() -= fsd.width * txt.size() * (txtVec.x()+1)/2;
        p->drawText(txtPos, txt);
        //auto txtPos = 0;

        p->drawLine(vec * r2, vec * r1);
    }
    p->drawEllipse(-r2, -r2, r2 * 2, r2 * 2);
    QString msg = "back";

    p->drawText(QPointF(-fsd.width * msg.size(), fsd.xHeight) / 2, msg);
}

void OperatorsKp::touchEvent(QTouchEvent* e) {
    if (e->touchPoints().size() != 1) return;
    auto& p = e->touchPoints()[0];
    if (p.state() != Qt::TouchPointPressed) return;
    press(p.pos().x(), p.pos().y());
}
void OperatorsKp::mousePressEvent(QMouseEvent* e) {
    press(e->pos().x(), e->pos().y());
}


void OperatorsKp::back() {
    if (state == State::Main)
        gotoMain();
    else
        setState(State::Main);

}
void OperatorsKp::press(qreal x, qreal y) {
    x -= width() / 2;
    y -= height() / 2;
    auto sz2 = x*x + y*y;
    if (sz2 <= r2*r2) {
        back();
    }
    else if (sz2 <= r1*r1){
        auto size = currStateData().size();
        auto a = qAtan2(y, x) + M_PI_2;
        if (a < 0) a += M_PI * 2;
        auto btn = size_t(a/ M_PI / 2 *size + 0.5);
        if (btn >= size) btn = 0;
        auto fun = currStateData()[btn].fun;
        fun(this);
    }
}
