#!/home/azbyn/Projects/qt_ts/qt_ts
a = 4;
b = 2;
fun add(a) {
    fun addA(b) { a + b; }
    #addA;
}
a = 9;
b += 1;
add2 = add(2);
println(add2(5));
println(add2(7));
fun addB(x) { b + x; }
println(addB(1));
#TODO: add properties (make Pi one)
