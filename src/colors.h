#ifndef COLORS_H
#define COLORS_H
#include <QColor>
#include <QObject>

#include "misc.h"

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
//Q_PROPERTY(MessageBody* body READ body WRITE setBody NOTIFY bodyChanged)

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


#endif
