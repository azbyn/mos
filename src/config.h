#ifndef CONFIG_H
#define CONFIG_H
#include <QString>

namespace config {
constexpr char fontPathMono[] = ":/fonts/DejaVuSansMono.ttf";
constexpr char fontPathSans[] = ":/fonts/DejaVuSans.ttf";
constexpr int fontSize =
#ifdef ANDROID
    16;
#else
    14;
#endif
constexpr int fontSizeOutput = fontSize;
constexpr int fontSizeNumber = 20;
constexpr float cursorPerc = 0.2f;
constexpr bool hasLineNumbers = true;
constexpr int indentSize = 4;

extern QString fontFamMono;
extern QString fontFamSans;
extern const char* file;
void start();
} // namespace config
#endif
