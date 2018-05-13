#ifndef PAGE_TYPE_H
#define PAGE_TYPE_H

#include <QObject>
namespace PageType {
Q_NAMESPACE
enum Type {
    Edit,
    In,
    Out,
    View,
    Options = 5,
};
Q_ENUM_NS(Type)  // register the enum in meta object data
}
#endif
