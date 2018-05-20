#!/home/azbyn/Projects/d_throwaway/throwaway_script
fun sort(data) {
    size = data.Size();
    for (a in range(1, size)) {
        for (b in range(size - 1, a -1, -1)) {
            if (data[b-1] > data[b]) {
                t = data[b-1];
                data[b-1] = data[b];
                data[b] = t;
            }
        }
    }
    return data;
}
for (a in range(7, 1, -1)) {
    println("a=", a);
}
d = [3,54,4, 0, 8, 65];
sorted = sort(d);
println("s=", sorted);
println("d=", d);
#TODO add properties (make Pi one)
