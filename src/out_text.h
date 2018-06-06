#ifndef OUT_TEXT_H
#define OUT_TEXT_H

#include "colors.h"
#include "font_size_data.h"

#include <QQuickPaintedItem>

enum Attr : uint8_t {
    A_DEFAULT = 0,
    A_BOLD = 1 << 1,
    A_ITALIC = 1 << 2,
    A_UNDERLINE = 1 << 3,

    A_NEWLINE = 1 << 7,
    //A_REVERSE = 1 << 4,
};
class OutText : public QQuickPaintedItem {
    Q_OBJECT
private:
    struct Data {
        QString str;
        Attr flags;
        QRgb fg;
        QRgb bg;
        Data();
        Data(Attr flags);
        Data(Attr flags, QRgb fg, QRgb bg);
        Data(const QString& str, const Data& d, Attr flags);
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
    friend void tsputs(const ushort* sh, size_t len);
    friend void tsputnl();
    friend void tsclear();

    friend uint8_t tsGetFlags();
    friend void tsSetFlags(uint8_t v);

    friend uint32_t tsGetBg();
    friend void tsSetBg(uint32_t v);

    friend uint32_t tsGetFg();
    friend void tsSetFg(uint32_t v);
};
void tsattr();
void tsattr(uint8_t flags, uint32_t fg, uint32_t bg);
void tsputs(const ushort* sh, size_t len);
void tsputnl();
void tsclear();

uint8_t tsGetFlags();
void tsSetFlags(uint8_t v);
uint32_t tsGetBg();
void tsSetBg(uint32_t v);
uint32_t tsGetFg();
void tsSetFg(uint32_t v);


#endif
