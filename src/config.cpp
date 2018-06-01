#include "config.h"

#include <QFontDatabase>


namespace config {
QString fontFamMono = "";
QString fontFamSans = "";
static QString getFam(const char* path) {
    int id = QFontDatabase::addApplicationFont(path);
    return QFontDatabase::applicationFontFamilies(id).at(0);
}
void start() {
    fontFamMono = getFam(fontPathMono);
    fontFamSans = getFam(fontPathSans);
}

}
