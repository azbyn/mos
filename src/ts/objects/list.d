module ts.objects.list;

import ts.objects;
import ts.runtime.env;
import ts.ast.token;
import stdd.conv;
import stdd.format;

mixin TSModule!(ts.objects.list);

@tsexport struct List {
    Obj[] val;
    this(Obj[] val) {
        this.val = val;
    }
static:
    mixin TSType!"list";
    @tsexport {
        void ctor(List v) { v.val = []; }
        tsstring toString(Pos p, Env e, List v) {
            tsstring res = "[";
            foreach (o;v.val)
                res ~= o.toStr(p,e) ~", ";
            return res ~ "]";
        }

        @tsget tsint Size(List v) { return v.val.length; }
        void add(List* v, Obj a) { v.val ~= a; }
        Obj opIndex(Pos pos, Env e, List v, tsint i) {
            //writefln("[%s] (len = %d)", i, Size(v));
            return v.val[i];
        }
        Obj opIndexSet(Pos pos, Env env, List* v, tsint i, Obj obj) {
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
            mixin TSType!"list_iterator";
            @tsexport {
                @tsget auto Iter(Iterator v) { return v; }
                @tsget Obj Val(Iterator v) { return *v.ptr; }
                @tsget tsint Index(Iterator v) { return v.ptr-v.beg; }
                bool next(Iterator* v) { return ++v.ptr < v.end; }
            }
        }
        @tsget Iterator Iter(List v) { return Iterator(v); }
    }
}
