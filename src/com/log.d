module com.str;

import mos.types;
import stdd.string;

extern (C++, com) void moslog(const(char)* str);

void moslog(string s) {
    com.moslog(s.toStringz);
}
void moslog(string f, A...)(A args) {
    import stdd.format;
    moslog(format!f(args));
}
void moslog(mosstring s) {
    import stdd.conv : to;
    moslog(s.to!string);
}
