module com.str;

import ts.types;
import stdd.string;

extern (C++, com) void tslog(const(char)* str);

void tslog(string s) {
    com.tslog(s.toStringz);
}
void tslog(string f, A...)(A args) {
    import stdd.format;
    tslog(format!f(args));
}
void tslog(tsstring s) {
    import stdd.conv : to;
    tslog(s.to!string);
}
