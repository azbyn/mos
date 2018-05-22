#ifndef EDITOR_TEXT_BASE_H
#define EDITOR_TEXT_BASE_H

#include <QQuickPaintedItem>

struct FontSizeData {
    float width, height, ascent;

    FontSizeData() = default;
    FontSizeData(const QFont& font);
};

class EditorTextBase : public QQuickPaintedItem {
    Q_OBJECT
protected:
    QFont font;
    FontSizeData fsd;
    bool isActive = true;

protected:
    explicit EditorTextBase(QQuickItem* parent = nullptr, int fontSize = 14);
    virtual QPoint origin() const = 0;

    void drawCursor(QPainter* p, int xCurr, int yCurr) const;

    virtual void setCursorScreen(QPointF p) = 0;
public:
    virtual ~EditorTextBase() = default;
public slots:
    //virtual void cursorLeft() = 0;
    //virtual void cursorRight() = 0;
    void setActive(bool a);

protected:
    virtual void paint(QPainter* painter) override = 0;
    void touchEvent(QTouchEvent* e) override;
    void mousePressEvent(QMouseEvent* e) override;
};


#endif
