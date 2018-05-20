#ifndef CONFIG_H
#define CONFIG_H
namespace config {
constexpr char fontPath[] = ":/fonts/DejaVuSansMono.ttf";
constexpr int fontSize =
#ifdef ANDROID
    16;
#else
    14;
#endif
constexpr int fontSizeNumber = 20;
constexpr float cursorPerc = 0.2f;
constexpr bool hasLineNumbers = true;
constexpr int indentSize = 4;
extern const char* file;
} // namespace config
#endif
