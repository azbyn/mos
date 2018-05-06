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

Q_NAMESPACE
// clang-format on
} // namespace colors
#endif
