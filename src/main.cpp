#include "editor_text.h"
#include "keypad_type.h"
#include "number_text.h"
#include "colors.h"

#include <cmath>

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>

int mainCpp(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<EditorText>("ts", 1, 0, "EditorText");
    qmlRegisterType<NumberText>("ts", 1, 0, "NumberText");
    qmlRegisterUncreatableMetaObject(
        KeypadType::staticMetaObject,
        "ts", 1, 0,
        "KeypadType",
        "Error: only enums");

    qmlRegisterSingletonType<Colors_qml>(
        "ts", 1, 0, "Colors",
        [](QQmlEngine*, QJSEngine*) -> QObject* {
            auto p = new Colors_qml();
            return p;
        });


    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
