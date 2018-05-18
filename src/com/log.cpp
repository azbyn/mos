#include "log.h"

#include <QtDebug>

namespace com {
void tslog(const char* str) { qDebug("%s", str); }
}
