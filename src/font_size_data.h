#ifndef FONT_SIZE_DATA_H
#define FONT_SIZE_DATA_H

#include <QFontMetricsF>

struct FontSizeData {
    float width, height, ascent, xHeight;

    FontSizeData() = default;
    FontSizeData(const QFont& font) {
        QFontMetricsF fm(font);
        QString str = "65465415241002.35-sadsajnkl;nhjkns";
        width = fm.width(str)/str.size(); //fm.maxWidth();
        height = fm.height();
        ascent = fm.ascent();
        xHeight = fm.xHeight();
    }
};
#endif
