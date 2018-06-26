module mos.objects.list;

import mos.objects;
import mos.runtime.env;
import mos.ast.token;
import stdd.conv;
import stdd.format;

mixin MOSModule!(mos.objects.list);

@mosexport struct List {
    Obj[] val;
    this(Obj[] val) {
        this.val = val;
    }
static:
    mixin MOSType!"list";
    @mosexport {
        void ctor(List v) { v.val = []; }
        mosstring toString(Pos p, Env e, List v) {
            mosstring res = "[";
            foreach (o;v.val)
                res ~= o.toStr(p,e) ~", ";
            return res ~ "]";
        }

        @mosget mosint Size(List v) { return v.val.length; }
        void add(List* v, Obj a) { v.val ~= a; }
        Obj opIndex(Pos pos, Env e, List v, mosint i) {
            //writefln("[%s] (len = %d)", i, Size(v));
            return v.val[i];
        }
        Obj opIndexSet(Pos pos, Env env, List* v, mosint i, Obj obj) {
            //writefln("set[%s] (len = %d)", i, Size(v));
            return v.val[i] = obj;
        }

        //List opCat(List v, Obj a) { return List(v.val ~ a); }
        bool toBool(List v) { return v.val.length != 0; }
        List dup(List v) { return List(v.val.dup()); }
        bool opEquals(Pos p, Env e, List v, Obj oth) {
            return oth.visitO!(
                (List o) {
                    if (o.val.length != v.val.length) return false;
                    Obj* i1 = v.val.ptr;
                    Obj* i2 = o.val.ptr;
                    Obj* end = v.val.ptr + v.val.length;
                    while (i1 != end) {
                        if (!i1.equals(p,e, *i2)) return false;
                        ++i1;
                        ++i2;
                    }
                    return true;
                },
                () => false);
        }
        struct Iterator {
            Obj* beg;
            Obj* end;
            Obj* ptr;
            this(List l) {
                beg = ptr = l.val.ptr;
                end = beg + l.val.length;
            }
        static:
            mixin MOSType!"list_iterator";
            @mosexport {
                @mosget auto Iter(Iterator v) { return v; }
                @mosget Obj Val(Iterator v) { return *v.ptr; }
                @mosget mosint Index(Iterator v) { return v.ptr-v.beg; }
                bool next(Iterator* v) { return ++v.ptr < v.end; }
            }
        }
        @mosget Iterator Iter(List v) { return Iterator(v); }
    }
}
