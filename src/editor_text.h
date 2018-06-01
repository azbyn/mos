#ifndef EDITOR_TEXT_H
#define EDITOR_TEXT_H

#include "editor_text_base.h"
#include "ts/ast/token.h"

#include <vector>

class EditorText : public EditorTextBase {
    Q_OBJECT
private:
    friend struct IndentationHelper;

    QFont bold;
    float minWidth;
    float minHeight;

    Q_PROPERTY(float minWidth READ getMinWidth WRITE setMinWidth NOTIFY minWidthChanged)
    Q_PROPERTY(float minHeight READ getMinHeight WRITE setMinHeight NOTIFY minHeightChanged)

public:
    static EditorText* Instance;
    explicit EditorText(QQuickItem* parent = nullptr);
    ~EditorText() override = default;

    float getMinWidth() const;
    void setMinWidth(float value);

    float getMinHeight() const;
    void setMinHeight(float value);

//public slots:
//   QString getFontName() const { return font.family(); }

protected:
    QPoint origin() const override;
    void paint(QPainter* painter) override;
    void setCursorScreen(QPointF p) override;

public:
signals:
    void minHeightChanged();
    void minWidthChanged();
};

#endif // EDITOR_TEXT_H
