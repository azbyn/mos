#ifndef MISC_H
#define MISC_H
#include <cstdint>

int digits(uint64_t num) {
    if (num < 10l) return 1;
    if (num < 100l) return 2;
    if (num < 1000l) return 3;
    if (num < 10000l) return 4;
    if (num < 100000l) return 5;
    if (num < 1000000l) return 6;
    if (num < 10000000l) return 7;
    if (num < 100000000l) return 8;
    if (num < 1000000000l) return 9;
    if (num < 10000000000l) return 10;
    if (num < 100000000000l) return 11;
    if (num < 1000000000000l) return 12;
    if (num < 10000000000000l) return 13;
    if (num < 100000000000000l) return 14;
    if (num < 1000000000000000l) return 15;
    if (num < 10000000000000000l) return 16;
    if (num < 100000000000000000l) return 17;
    if (num < 1000000000000000000l) return 18;
    return 19;
}

#endif
