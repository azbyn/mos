module ts.objects.list;

import ts.objects;
import ts.runtime.env;
import ts.ast.token;
import stdd.conv;
import stdd.format;

struct List {
    Obj[] val;
    this(Obj[] val) {
        this.val = val;
    }
static:
    void ctor(List v) { v.val = []; }
    tsstring toString(List v) {
        tsstring res = "[";
        foreach (o;v.val)
            res ~= o.toStr() ~", ";
        return res ~ "]";
    }
    tsstring type() { return "list"; }

    tsint Size(List v) { return v.val.length; }
    void add(List v, Obj a) { v.val ~= a; }
    Obj opIndex(Pos pos, Env e, List v, tsint i) {
        //writefln("[%s] (len = %d)", i, Size(v));
        return v.val[i];
    }
    Obj opIndexSet(Pos pos, Env env, List v, tsint i, Obj obj) {
        //writefln("set[%s] (len = %d)", i, Size(v));

        return v.val[i] = obj;
    }

    //List opCat(List v, Obj a) { return List(v.val ~ a); }
    bool toBool(List v) { return v.val.length != 0; }
    ListIter Iter(List v) { return ListIter(v); }
}
struct ListIter {
    Obj* beg;
    Obj* end;
    Obj* ptr;
    this(List l) {
        beg = ptr = l.val.ptr;
        end = beg + l.val.length;
    }
static:
    tsstring type() { return "list_iterator"; }
    ListIter Iter(ListIter v) { return v; }
    Obj  Val(ListIter v) { return *v.ptr; }
    tsint Index(ListIter v) { return v.ptr-v.beg; }
    bool next(ListIter* v) { return ++v.ptr < v.end; }
}
