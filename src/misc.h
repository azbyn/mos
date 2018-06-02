#ifndef MISC_H
#define MISC_H

#include <QString>
#include <cstdint>
/*
typedef int Pos;

struct TsException : std::exception {
    Pos pos;
    QString msg;
    TsException(Pos pos, const QString& msg) {
        this->pos = pos;
        this->msg = msg;
    }
    virtual const char* what() const throw() {
        return "Please get the QString msg";
    }
    };*/

constexpr int digits(uint64_t num) {
    // clang-format off
    return (num < 10l) ? 1 :
        (num < 100l) ? 2 :
        (num < 1000l) ? 3 :
        (num < 10000l) ? 4 :
        (num < 100000l) ? 5 :
        (num < 1000000l) ? 6 :
        (num < 10000000l) ? 7 :
        (num < 100000000l) ? 8 :
        (num < 1000000000l) ? 9 :
        (num < 10000000000l) ? 10 :
        (num < 100000000000l) ? 11 :
        (num < 1000000000000l) ? 12 :
        (num < 10000000000000l) ? 13 :
        (num < 100000000000000l) ? 14 :
        (num < 1000000000000000l) ? 15 :
        (num < 10000000000000000l) ? 16 :
        (num < 100000000000000000l) ? 17 :
        (num < 1000000000000000000l) ? 18 :
        19;
    // clang-format on
}

#define Q_PROP_RO(_type, _name, _val)          \
    Q_INVOKABLE _type _name() { return _val; } \
    Q_PROPERTY(_type _name READ _name CONSTANT);

#endif
