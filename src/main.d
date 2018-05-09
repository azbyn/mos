//import std.stdio;

//extern(C++) void main(){}
extern(C++) int mainCpp(int argc, char** argv);

//useful link:
//https ://wiki.dlang.org/Runtime_internals
extern(C) int main(int argc, char **argv) {    return mainCpp(argc, argv);}
//void main(){}

/*extern(C):
void _tlsend() {}
void _tlsstart() {}*/
