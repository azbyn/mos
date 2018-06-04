module ts.ir.lib;

import stdd.array;
import ts.objects.obj;

class Lib {
    private Obj[] objs;
    private tsstring[] names;
    this(Obj[tsstring] map) {
        objs = uninitializedArray!(Obj[])(map.length);
        names = uninitializedArray!(tsstring[])(map.length);
        size_t i = 0;
        foreach (n, o; map) {
            names[i] = n;
            objs[i] = o;
            ++i;
        }
    }

    bool get(tsstring name, out size_t res) {
        foreach (i, n; names) {
            if (n == name) {
                res = i;
                return true;
            }
        }
        return false;
    }

    Obj get(size_t i) {
        return objs[i];
    }
    tsstring getName(size_t i){
        return names[i];
    }
}
