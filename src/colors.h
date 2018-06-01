#ifndef COLORS_H
#define COLORS_H
#include <QColor>
#include <QObject>

#include "misc.h"
namespace colors {
// clang-format off
constexpr QRgb base00_rgb = 0xff1D1F21;
constexpr QRgb base01_rgb = 0xff282A2E;
constexpr QRgb base02_rgb = 0xff373B41;
constexpr QRgb base03_rgb = 0xff969896;
constexpr QRgb base04_rgb = 0xffB4B7B4;
constexpr QRgb base05_rgb = 0xffE0E0E0;
constexpr QRgb base06_rgb = 0xffF0F0F0;
constexpr QRgb base07_rgb = 0xffFFFFFF;
constexpr QRgb base08_rgb = 0xffCC342B;
constexpr QRgb base09_rgb = 0xffF96A38;
constexpr QRgb base0A_rgb = 0xffFBA922;
constexpr QRgb base0B_rgb = 0xff198844;
constexpr QRgb base0C_rgb = 0xff12A59C;
constexpr QRgb base0D_rgb = 0xff3971ED;
constexpr QRgb base0E_rgb = 0xffA36AC7;
constexpr QRgb base0F_rgb = 0xffFBA922;

const QColor base00(base00_rgb);
const QColor base01(base01_rgb);
const QColor base02(base02_rgb);
const QColor base03(base03_rgb);
const QColor base04(base04_rgb);
const QColor base05(base05_rgb);
const QColor base06(base06_rgb);
const QColor base07(base07_rgb);
const QColor base08(base08_rgb);
const QColor base09(base09_rgb);
const QColor base0A(base0A_rgb);
const QColor base0B(base0B_rgb);
const QColor base0C(base0C_rgb);
const QColor base0D(base0D_rgb);
const QColor base0E(base0E_rgb);
const QColor base0F(base0F_rgb);

const QColor background      = base00;
const QColor cursor          = base05;
const QColor defaults        = base05;
const QColor brackets        = base05;
const QColor operators       = base05;
const QColor delimiters      = base05;
const QColor functions       = base0D;
const QColor variables       = base05;
const QColor numbers         = base09;
const QColor constants       = base09;
const QColor strings         = base0B;
const QColor keywords        = base0E;
const QColor classes         = base0A;
const QColor escapeSequences = base0A;
// clang-format on
} // namespace colors

class Colors_qml : public QObject {
    Q_OBJECT
public:
    Colors_qml() = default;
//public:
    Q_PROP_RO(QColor, base00, colors::base00);
    Q_PROP_RO(QColor, base01, colors::base01);
    Q_PROP_RO(QColor, base02, colors::base02);
    Q_PROP_RO(QColor, base03, colors::base03);
    Q_PROP_RO(QColor, base04, colors::base04);
    Q_PROP_RO(QColor, base05, colors::base05);
    Q_PROP_RO(QColor, base06, colors::base06);
    Q_PROP_RO(QColor, base07, colors::base07);
    Q_PROP_RO(QColor, base08, colors::base08);
    Q_PROP_RO(QColor, base09, colors::base09);
    Q_PROP_RO(QColor, base0A, colors::base0A);
    Q_PROP_RO(QColor, base0B, colors::base0B);
    Q_PROP_RO(QColor, base0C, colors::base0C);
    Q_PROP_RO(QColor, base0D, colors::base0D);
    Q_PROP_RO(QColor, base0E, colors::base0E);
    Q_PROP_RO(QColor, base0F, colors::base0F);
};

enum class Color {
    Base00 = 0,
    Base01 = 1,
    Base02 = 2,
    Base03 = 3,
    Base04 = 4,
    Base05 = 5,
    Base06 = 6,
    Base07 = 7,
    Base08 = 8,
    Base09 = 9,
    Base0A = 10,
    Base0B = 11,
    Base0C = 12,
    Base0D = 13,
    Base0E = 14,
    Base0F = 15,

    Black = 0,
    Background = 0,
    Default = 5,
    DarkGrey = 1,
    LightGrey = 3,
    White = 7,
    Red = 8,
    Orange = 9,
    Yellow = 10,
    Green = 11,
    Cyan = 12,
    Blue = 13,
    Purple = 14,
    Brown = 15,
};
constexpr QRgb getColor(Color color) {
    switch (color) {
    case Color::Base00: return colors::base00_rgb;
    case Color::Base01: return colors::base01_rgb;
    case Color::Base02: return colors::base02_rgb;
    case Color::Base03: return colors::base03_rgb;
    case Color::Base04: return colors::base04_rgb;
    case Color::Base05: return colors::base05_rgb;
    case Color::Base06: return colors::base06_rgb;
    case Color::Base07: return colors::base07_rgb;
    case Color::Base08: return colors::base08_rgb;
    case Color::Base09: return colors::base09_rgb;
    case Color::Base0A: return colors::base0A_rgb;
    case Color::Base0B: return colors::base0B_rgb;
    case Color::Base0C: return colors::base0C_rgb;
    case Color::Base0D: return colors::base0D_rgb;
    case Color::Base0E: return colors::base0E_rgb;
    case Color::Base0F: return colors::base0F_rgb;
    }
    return 0;// Q_ASSERT(0);
    //return
}

enum Attributes : uint8_t {
    A_DEFAULT = 0,
    A_BOLD = 1 << 1,
    A_ITALIC = 1 << 2,
    A_UNDERLINE = 1 << 3,

    A_NEWLINE = 1 << 7,
    //A_REVERSE = 1 << 4,
};



#endif
