#ifndef NUMBER_TEXT_H
#define NUMBER_TEXT_H

#include "editor_text_base.h"

class NumberText : public EditorTextBase {
    Q_OBJECT
private:
    int cursor = 0;
    QString val = "";

public:
    explicit NumberText(QQuickItem* parent = nullptr);
    ~NumberText() override = default;

public slots:
    void addChar(const QString& s);
    void del();
    void reset();
    void cursorLeft() override;
    void cursorRight() override;
    void setCursor(int c);
    bool ok();
protected:
    QPoint origin() const override;

    int length() const;
    void paint(QPainter* painter) override;

    void setCursorScreen(QPointF p) override;

    //void setCursorScreen(QPointF p) override;
signals:
    void invalidate();
    void validate();
};

#endif // NUMBER_TEXT_H
