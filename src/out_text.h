#ifndef OUT_TEXT_H
#define OUT_TEXT_H

#include "colors.h"
#include "font_size_data.h"

#include <QQuickPaintedItem>

class OutText : public QQuickPaintedItem {
    Q_OBJECT
private:
    struct Data {
        QString str;
        Attributes flags;
        QRgb fg;
        QRgb bg;
        Data();
        Data(Attributes flags);
        Data(Attributes flags, QRgb fg, QRgb bg);
        Data(Attributes flags, Color fg, Color bg);
        Data(const QString& str, const Data& d, Attributes flags);
        constexpr bool operator==(const Data& rhs) const;
        constexpr bool operator!=(const Data& rhs) const;
    };
    QFont font;
    FontSizeData fsd;
    static std::vector<Data> vec;
    static OutText* Instance;

public:
    static void init();
    explicit OutText(QQuickItem* parent = nullptr);

private:
    void paint(QPainter* painter) override;
    static void clear();
    static void append(const QString& s);
    static void setAttribute(Data&& data);

public:
    friend void tsattr();
    friend void tsattr(uint8_t flags, uint32_t fg, uint32_t bg);
    friend void tsattr(uint8_t flags, Color fg, Color bg);
    friend void tsputs(const ushort* sh, size_t len);
    friend void tsputnl();
    friend void tsclear();
};
void tsattr();
void tsattr(uint8_t flags, uint32_t fg, uint32_t bg);
void tsattr(uint8_t flags, Color fg, Color bg);
void tsputs(const ushort* sh, size_t len);
void tsputnl();
void tsclear();

#endif
