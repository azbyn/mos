#ifndef KEYPAD_TYPE_H
#define KEYPAD_TYPE_H

#include <QObject>
namespace KeypadType {
Q_NAMESPACE
enum Type {
    Main,

    Number,
    String,
    OtherObjs,
    Operators,

    Newline,
    Vars,
    Libs,
    Statements,

    Semicolon,
    Curly,
    Round,
    Comma,

};
Q_ENUM_NS(Type)  // register the enum in meta object data
}
#endif
