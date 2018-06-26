#include "log.h"

#include <QtDebug>

namespace com {
void moslog(const char* str) { qDebug("%s", str); }
}
