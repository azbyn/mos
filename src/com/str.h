#ifndef DSTR_H
#define DSTR_H
#include <QString>
namespace com {
struct Str {
    QString qstr;

    Str() = default;
    Str(const QString& q) : qstr(q) {}
    Str(const char* str) : qstr(str) {}
    Str(const char* str, size_t size);
    int size() const;
    operator QString() const { return qstr; }
};
}

using namespace com;

#endif
