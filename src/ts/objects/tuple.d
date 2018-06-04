module ts.objects.tuple;

import ts.objects;
import ts.runtime.env;
import ts.ast.token;
import stdd.conv;
import stdd.format;
import stdd.array;

private alias Tuple = Tuple_;
struct Tuple_ {
    Obj[] val;
    this(Obj[] val) {
        this.val = val;
    }
static:
    void ctor(Tuple* v) { v.val = []; }
    void ctor(Tuple* v, Tuple o) {
        v.val = o.val;
    }
    tsstring toString(Pos p, Env e, Tuple v) {
        tsstring res = "(";
        foreach (o; v.val)
            res ~= o.toStr(p, e) ~", ";
        return res ~ ")";
    }
    tsstring type() { return "tuple"; }

    tsint Size(Tuple v) { return v.val.length; }
    Obj opIndex(Pos pos, Tuple v, tsint i) {
        return v.val[i];
    }

    Obj Head(Tuple t) { return t.val[0]; }
    Tuple Tail(Tuple t) { return Tuple(t.val[1..$]); }

    bool toBool(Tuple v) { return v.val.length != 0; }
    Tuple dup(Tuple v) { return Tuple(v.val.dup()); }
    bool opEquals(Pos p, Env e, Tuple v, Obj oth) {
        return oth.val.tryVisit!(
            (Tuple o) {
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

    TupleIter Iter(Tuple v) { return TupleIter(v); }
}
struct TupleIter {
    Obj* beg;
    Obj* end;
    Obj* ptr;
    this(Tuple l) {
        beg = ptr = l.val.ptr;
        end = beg + l.val.length;
    }
static:
    tsstring type() { return "tuple_iterator"; }
    TupleIter Iter(TupleIter v) { return v; }
    Obj  Val(TupleIter v) { return *v.ptr; }
    tsint Index(TupleIter v) { return v.ptr-v.beg; }
    bool next(TupleIter* v) { return ++v.ptr < v.end; }
}

