#include "editor_text.h"
#include "keypad_type.h"
#include "number_text.h"

#include <QGuiApplication>
#include <QQmlApplicationEngine>
#include <QQmlEngine>

int mainCpp(int argc, char *argv[]) {
    QCoreApplication::setAttribute(Qt::AA_EnableHighDpiScaling);

    QGuiApplication app(argc, argv);

    qmlRegisterType<EditorText>("ts", 1, 0, "EditorText");
    qmlRegisterType<NumberText>("ts", 1, 0, "NumberText");
    qmlRegisterUncreatableMetaObject(
        KeypadType::staticMetaObject, // static meta object
        "ts",                         // import statement (can be any string)
        1, 0,                         // major and minor version of the import
        "KeypadType",                 // name in QML (does not have to match C++ name)
        "Error: only enums"           // error in case someone tries to create a MyNamespace object
        );

    QQmlApplicationEngine engine;
    engine.load(QUrl(QStringLiteral("qrc:/main.qml")));
    if (engine.rootObjects().isEmpty())
        return -1;

    return app.exec();
}
