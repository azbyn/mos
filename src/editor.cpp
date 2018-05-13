#include "editor.h"

#include "editor_text.h"

Editor* Editor::instance= nullptr;
Editor::Editor() {
    if (instance != nullptr) throw "EXPECTED ONE INSTANCE OF Editor";
    instance = this;
}

void Editor::addToken(TT type, const QString& msg) {
    EditorText::instance->addToken(type, msg);
}
void Editor::run() {
    qInfo() << "WIP";
}
