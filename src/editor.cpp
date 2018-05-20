#include "editor.h"

#include "editor_text.h"

void tsrun(const DToken* ptr, int len);

Editor* Editor::instance= nullptr;
Editor::Editor() {
    if (instance != nullptr) throw "EXPECTED ONE INSTANCE OF Editor";
    instance = this;
}

void Editor::addToken(TT type, const QString& msg) {
    EditorText::instance->addToken(type, msg);
}
void Editor::puts(const QString& value) {
    appendOut(value);
}
void Editor::run() {
    setOut("");
    //QVector<DToken> toks;
    std::vector<DToken> toks;
    for (auto& line : EditorText::instance->data) {
        //toks.reserve(toks.size() + line.size());
        for (auto& t : line) 
            //toks.push_back(DToken(t));
            toks.emplace_back(t);
        toks.emplace_back(TT::newLine);
        //toks.insert(toks.end(), line.begin(), line.end());
    }
    //test(DToken(Token(TT::eof, "hello"));

    tsrun(toks.data(), toks.size());
}
QString Editor::getFontName() const { return EditorText::instance->getFontName(); }


void tsputs(const ushort* sh, size_t len) {
    Editor::instance->puts(QString::fromUtf16(sh, len));
}
