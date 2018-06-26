module mos.ir.lib;

import stdd.array;
import mos.objects.obj;

class Lib {
    private Obj[] objs;
    private mosstring[] names;
    this(Obj[mosstring] map) {
        objs = uninitializedArray!(Obj[])(map.length);
        names = uninitializedArray!(mosstring[])(map.length);
        size_t i = 0;
        foreach (n, o; map) {
            names[i] = n;
            objs[i] = o;
            ++i;
        }
    }

    bool get(mosstring name, out size_t res) {
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
    mosstring getName(size_t i){
        return names[i];
    }
    void append(Obj[mosstring] map) {
        foreach (n, o; map) {
            size_t r;
            assert(!get(n, r), format!"'%s' already exists in lib"(n));

            names ~= n;
            objs ~= o;
        }

    }
}
