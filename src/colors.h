#ifndef COLORS_H
#define COLORS_H
#include <QColor>
#include <QObject>

namespace colors {
// clang-format off
const QColor base00(0xff1D1F21);
const QColor base01(0xff282A2E);
const QColor base02(0xff373B41);
const QColor base03(0xff969896);
const QColor base04(0xffB4B7B4);
const QColor base05(0xffE0E0E0);
const QColor base06(0xffF0F0F0);
const QColor base07(0xffFFFFFF);
const QColor base08(0xffCC342B);
const QColor base09(0xffF96A38);
const QColor base0A(0xffFBA922);
const QColor base0B(0xff198844);
const QColor base0C(0xff12A59C);
const QColor base0D(0xff3971ED);
const QColor base0E(0xffA36AC7);
const QColor base0F(0xffFBA922);

const QColor background      = base00;
const QColor cursor          = base05;
const QColor defaults        = base05;
const QColor brackets        = base05;
const QColor operators       = base05;
const QColor delimiters      = base05;
const QColor functions       = base0D;
const QColor variables       = base05;
const QColor numbers         = base09;
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
public slots:
    QColor getBase00() { return colors::base00; }
    QColor getBase01() { return colors::base01; }
    QColor getBase02() { return colors::base02; }
    QColor getBase03() { return colors::base03; }
    QColor getBase04() { return colors::base04; }
    QColor getBase05() { return colors::base05; }
    QColor getBase06() { return colors::base06; }
    QColor getBase07() { return colors::base07; }
    QColor getBase08() { return colors::base08; }
    QColor getBase09() { return colors::base09; }
    QColor getBase0A() { return colors::base0A; }
    QColor getBase0B() { return colors::base0B; }
    QColor getBase0C() { return colors::base0C; }
    QColor getBase0D() { return colors::base0D; }
    QColor getBase0E() { return colors::base0E; }
    QColor getBase0F() { return colors::base0F; }
};


#endif
