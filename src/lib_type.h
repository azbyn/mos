#ifndef LIB_TYPE_H
#define LIB_TYPE_H

#include <QObject>
namespace LibType {
Q_NAMESPACE
enum Type {
    Main,

    IO,
    Math,
    Misc,
};
Q_ENUM_NS(Type)  // register the enum in meta object data
}
#endif
