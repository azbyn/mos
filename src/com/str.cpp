#include "str.h"

namespace com {
Str::Str(const char* str, size_t size)
    : qstr(QString::fromUtf8(str, size)) {}

int Str::size() const { return qstr.size(); }
}
