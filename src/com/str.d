module com.str;

extern(C++, com) class Str {
    this(const char* str, size_t size);

    //this()
    int size() const;
}
