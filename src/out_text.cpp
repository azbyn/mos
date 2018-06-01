#include "out_text.h"

#include "config.h"

#include <QPainter>

OutText* OutText::Instance = nullptr;
std::vector<OutText::Data> OutText::vec;

OutText::Data::Data()
    : Data(A_DEFAULT, Color::Default, Color::Background) {}
OutText::Data::Data(Attributes flags)
    : Data(flags, Color::Default, Color::Background) {}
OutText::Data::Data(Attributes flags, QRgb fg, QRgb bg)
    : str(""), flags(flags), fg(fg), bg(bg) {}
OutText::Data::Data(Attributes flags, Color fg, Color bg)
    : Data(flags, getColor(fg), getColor(bg)) {}
OutText::Data::Data(const QString& str, const Data& d, Attributes flags)
    : str(str), flags((Attributes)(d.flags | flags)), fg(d.fg), bg(d.bg) {}

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
    font.setPointSize(config::fontSizeOutput);
    fsd = FontSizeData(font);
}
void OutText::clear() {
    vec.clear();
    vec.emplace_back();
    if (Instance)
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
}

void OutText::setAttribute(Data&& data) {
    if (data == vec.back()) return;
    vec.emplace_back(data);
}
constexpr int leftMargin = 2;
void OutText::paint(QPainter* p) {
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
    setHeight(vCursor.y() * fsd.height + fsd.ascent);
    setWidth(leftMargin + maxX * fsd.width);
}
void tsattr() {
    OutText::setAttribute(OutText::Data());
}
void tsattr(uint8_t flags, uint32_t fg, uint32_t bg) {
    OutText::setAttribute(OutText::Data((Attributes) flags, fg, bg));
}
void tsattr(uint8_t flags, Color fg, Color bg) {
    OutText::setAttribute(OutText::Data((Attributes) flags, fg, bg));
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
