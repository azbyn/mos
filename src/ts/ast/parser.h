#ifndef PARSER_H
#define PARSER_H

#include "token.h"
#include "misc.h"

#include <exception>
#include <QString>

struct ParserException : TsException {
    ParserException(Pos pos, const QString& msg) : TsException(pos, msg) {}
};

class Parser {
    
};

#endif
