#include "out_text.h"

#include "config.h"

#include <QPainter>

OutText* OutText::Instance = nullptr;
std::vector<OutText::Data> OutText::vec;

OutText::Data::Data()
    : Data(A_DEFAULT) {}
OutText::Data::Data(Attr flags)
    : Data(flags, colors::Base05_rgb, colors::Base00_rgb) {}
OutText::Data::Data(Attr flags, QRgb fg, QRgb bg)
    : str(""), flags(flags), fg(fg), bg(bg) {}
OutText::Data::Data(const QString& str, const Data& d, Attr flags)
    : str(str), flags((Attr)(d.flags | flags)), fg(d.fg), bg(d.bg) {}

constexpr bool OutText::Data::operator==(const Data& rhs) const {
    return flags == rhs.flags && fg == rhs.fg && bg == rhs.bg;
}
constexpr bool OutText::Data::operator!=(const Data& rhs) const {
    return flags != rhs.flags || fg != rhs.fg || bg != rhs.bg;
}

void OutText::init() {
    vec.emplace_back();
}

OutText::OutText(QQuickItem* parent)
    : QQuickPaintedItem(parent), font(config::fontFamMono) {
    if (Instance)
        throw std::runtime_error("EXPECTED ONE INSTANCE OF OutText");
    Instance = this;
    font.setPointSize(config::fontSizeOutput);
    fsd = FontSizeData(font);
    //qDebug("<<NEW OUT_TEXT");
}
void OutText::clear() {
    vec.clear();
    vec.emplace_back();
    //if (Instance)
        Instance->update();
}
void OutText::append(const QString& s) {
    if (s.size() == 0) return;
    auto lines = s.split('\n');
    Q_ASSERT(lines.length() > 0);
    auto it = lines.begin();
    auto last = lines.end() - 1;
    Q_ASSERT(vec.size() != 0);
    auto& attrs = vec.back();
    while (it != last) {
        vec.back().str += *it;
        vec.emplace_back("", attrs, A_NEWLINE);
        ++it;
    }
    vec.back().str += *it;
    ///qDebug() << "vec. back +=" << *it << "aka: " << vec.back().str;
    //if (Instance)
    Instance->update();
}

void OutText::setAttribute(Data&& data) {
    if (data == vec.back()) return;
    if (data.str.size() == 0) {
        auto prevNL = vec.back().flags & A_NEWLINE;
        data.flags = (Attr) (data.flags | prevNL);
        vec.back() = data;
    }
    else {
        vec.emplace_back(data);
    }
    //    Instance->update();

}
constexpr int leftMargin = 2;
void OutText::paint(QPainter* p) {
    //qDebug("<<paint %lu", vec.size());
    QPoint vCursor = {0, 0};
    int maxX = 0;
    for (auto& d : vec) {
        if (d.flags & A_NEWLINE) {
            if (maxX < vCursor.rx())
                maxX = vCursor.x();
            vCursor.rx() = 0;
            ++vCursor.ry();
        }
        auto len = d.str.size();
        if (len == 0) continue;
        QFont f = font;
        f.setBold(d.flags & A_BOLD);
        f.setItalic(d.flags & A_ITALIC);
        f.setUnderline(d.flags & A_UNDERLINE);
        p->setFont(f);
        p->setPen(d.fg);

        auto x = vCursor.x() * fsd.width + leftMargin;
        auto y = fsd.ascent + fsd.height * vCursor.y();
        p->fillRect(QRectF(x, y - fsd.ascent, fsd.width*len, fsd.height), d.bg);
        p->drawText(x, y, d.str);
        vCursor.rx() += len;
    }
    setHeight((vCursor.y() + 1) * fsd.height + fsd.ascent);
    setWidth(leftMargin + (maxX + 5) * fsd.width);
}
void tsattr() {
    OutText::setAttribute(OutText::Data());
}
void tsattr(uint8_t flags, uint32_t fg, uint32_t bg) {
    OutText::setAttribute(OutText::Data((Attr) flags, fg, bg));
}

void tsputnl() {
    OutText::vec.emplace_back(A_NEWLINE);
}

void tsputs(const ushort* sh, size_t len) {
    OutText::append(QString::fromUtf16(sh, len));
}
void tsclear() {
    OutText::clear();
}
uint8_t tsGetFlags() {
    return OutText::vec.back().flags;
}
void tsSetFlags(uint8_t v) {
    if (v == tsGetFlags()) return;
    tsattr(v, tsGetFg(), tsGetBg());
}
uint32_t tsGetBg() {
    return OutText::vec.back().bg;
}
void tsSetBg(uint32_t v) {
    if (v == tsGetBg()) return;
    tsattr(tsGetFlags(), tsGetFg(), v);
}
uint32_t tsGetFg() {
    return OutText::vec.back().fg;
}
void tsSetFg(uint32_t v) {
    if (v == tsGetFg()) return;
    tsattr(tsGetFlags(), v, tsGetBg());
}
