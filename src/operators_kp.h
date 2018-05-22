#ifndef OPERATORS_KP
#define OPERATORS_KP
#include <QQuickPaintedItem>

class OperatorsKp : public QQuickPaintedItem {
    Q_OBJECT
public:
    QFont font;
    explicit OperatorsKp(QQuickItem* parent = nullptr);

protected:
    virtual void paint(QPainter* painter) override;
public slots:

};

#endif
