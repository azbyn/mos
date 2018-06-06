#ifndef COLORS_H
#define COLORS_H
#include <QColor>
#include <QObject>

#include "misc.h"
namespace colors {
// clang-format off
QRgb base00();
QRgb base01();
QRgb base02();
QRgb base03();
QRgb base04();
QRgb base05();
QRgb base06();
QRgb base07();
QRgb base08();
QRgb base09();
QRgb base0A();
QRgb base0B();
QRgb base0C();
QRgb base0D();
QRgb base0E();
QRgb base0F();

constexpr QRgb Base00_rgb = 0xff1D1F21;
constexpr QRgb Base01_rgb = 0xff282A2E;
constexpr QRgb Base02_rgb = 0xff373B41;
constexpr QRgb Base03_rgb = 0xff969896;
constexpr QRgb Base04_rgb = 0xffB4B7B4;
constexpr QRgb Base05_rgb = 0xffE0E0E0;
constexpr QRgb Base06_rgb = 0xffF0F0F0;
constexpr QRgb Base07_rgb = 0xffFFFFFF;
constexpr QRgb Base08_rgb = 0xffCC342B;
constexpr QRgb Base09_rgb = 0xffF96A38;
constexpr QRgb Base0A_rgb = 0xffFBA922;
constexpr QRgb Base0B_rgb = 0xff198844;
constexpr QRgb Base0C_rgb = 0xff12A59C;
constexpr QRgb Base0D_rgb = 0xff3971ED;
constexpr QRgb Base0E_rgb = 0xffA36AC7;
constexpr QRgb Base0F_rgb = 0xffFBA922;

const QColor Base00(Base00_rgb);
const QColor Base01(Base01_rgb);
const QColor Base02(Base02_rgb);
const QColor Base03(Base03_rgb);
const QColor Base04(Base04_rgb);
const QColor Base05(Base05_rgb);
const QColor Base06(Base06_rgb);
const QColor Base07(Base07_rgb);
const QColor Base08(Base08_rgb);
const QColor Base09(Base09_rgb);
const QColor Base0A(Base0A_rgb);
const QColor Base0B(Base0B_rgb);
const QColor Base0C(Base0C_rgb);
const QColor Base0D(Base0D_rgb);
const QColor Base0E(Base0E_rgb);
const QColor Base0F(Base0F_rgb);

const QColor Background      = Base00;
const QColor Cursor          = Base05;
const QColor Defaults        = Base05;
const QColor Brackets        = Base05;
const QColor Operators       = Base05;
const QColor Delimiters      = Base05;
const QColor Functions       = Base0D;
const QColor Variables       = Base05;
const QColor Numbers         = Base09;
const QColor Constants       = Base09;
const QColor Strings         = Base0B;
const QColor Keywords        = Base0E;
const QColor Classes         = Base0A;
const QColor EscapeSequences = Base0A;
// clang-format on
} // namespace colors

class Colors_qml : public QObject {
    Q_OBJECT
public:
    Colors_qml() = default;
//public:
    Q_PROP_RO(QColor, Base00, colors::Base00);
    Q_PROP_RO(QColor, Base01, colors::Base01);
    Q_PROP_RO(QColor, Base02, colors::Base02);
    Q_PROP_RO(QColor, Base03, colors::Base03);
    Q_PROP_RO(QColor, Base04, colors::Base04);
    Q_PROP_RO(QColor, Base05, colors::Base05);
    Q_PROP_RO(QColor, Base06, colors::Base06);
    Q_PROP_RO(QColor, Base07, colors::Base07);
    Q_PROP_RO(QColor, Base08, colors::Base08);
    Q_PROP_RO(QColor, Base09, colors::Base09);
    Q_PROP_RO(QColor, Base0A, colors::Base0A);
    Q_PROP_RO(QColor, Base0B, colors::Base0B);
    Q_PROP_RO(QColor, Base0C, colors::Base0C);
    Q_PROP_RO(QColor, Base0D, colors::Base0D);
    Q_PROP_RO(QColor, Base0E, colors::Base0E);
    Q_PROP_RO(QColor, Base0F, colors::Base0F);
};


#endif
