#include "editor_text.h"
#include "keypad_type.h"
#include "lib_type.h"
#include "page_type.h"
#include "number_text.h"
#include "colors.h"
#include "editor.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>

#define REGISTER_ENUM(_name)          \
    qmlRegisterUncreatableMetaObject( \
        _name::staticMetaObject,      \
        "ts", 1, 0,                   \
        #_name,                       \
        "Error: only enums")

//extern "C" double log2(double x) { return std::log2(x); }
//void d_init();
//void d_end();
int mainCpp(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<EditorText>("ts", 1, 0, "EditorText");
    qmlRegisterType<NumberText>("ts", 1, 0, "NumberText");
    qmlRegisterType<Editor>("ts", 1, 0, "Editor");
    REGISTER_ENUM(KeypadType);
    REGISTER_ENUM(LibType);
    REGISTER_ENUM(PageType);


    qmlRegisterSingletonType<Colors_qml>(
        "ts", 1, 0, "Colors",
        [](QQmlEngine*, QJSEngine*) -> QObject* {
            auto p = new Colors_qml();
            return p;
        });


    /*
    qmlRegisterSingletonType<Editor>(
        "ts", 1, 0, "Editor",
        [](QQmlEngine*, QJSEngine*) -> QObject* {
            auto p = new Editor();
            return p;
            });*/
    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;
    return app.exec();
}
