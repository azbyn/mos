//import std.stdio;

//extern(C++) void main(){}
extern(C++) int mainCpp(int argc, char** argv);

//useful link:
//https ://wiki.dlang.org/Runtime_internals
extern(C) int main(int argc, char **argv) {
    import core.stdc.stdlib;
    d_init();
    atexit(&d_end);
    return mainCpp(argc, argv);
}
//*__gshared */void main() {}
//extern(C): void main(){}
extern(C):
void _tlsend() {}
void _tlsstart() {}
//import core.runtime;


extern(C) int rt_init();
extern(C) int rt_term();

import core.stdc.stdio;
extern(C) void d_init() { printf("d_init %d\n",rt_init()); }
extern(C) void d_end()  { printf("d_end %d\n", rt_term()); }
