module ts.objects.dict;

import ts.objects.obj;
import ts.ast.token;
import stdd.conv;
import stdd.format;
import ts.misc;
import ts.ast.token;
import ts.runtime.env;

struct Dict {
    //Obj[int] val;
    struct Pair { Obj key; Obj val; }
    Pair[] val;
    this(Pair[] val) {
        this.val = val;
    }
    this(Obj[] arr) {
        import stdd.array;
        debug assert(val.length % 2== 0);
        val = uninitializedArray!(Pair[])(arr.length/2);
        for (int i = 0; i < arr.length; i += 2) {
            val[i/2] = Pair(arr[i], arr[i+1]);
        }
    }
static:

    void ctor(Dict v) { v.val = []; }
    tsstring toString(Dict v) {
        tsstring res = "{";
        foreach (p; v.val)
            res ~= tsformat!"%s: %s, "(p.key.toStr, p.val.toStr);
        return res ~ "}";
    }

    tsstring type() { return "map"; }

    tsint size(Dict v) { return v.val.length; }
    Obj opIndex(Pos pos, Env env, Dict v, Obj index) {
        foreach (i, p; v.val) {
            if (p.key.equals(index)) {
                return v.val[i].val;
            }
        }
        throw new RuntimeException(pos, format!"Key '%s' not found"(index));
    }
    Obj opIndexSet(Dict v, Obj index, Obj obj) {
        foreach (i, p; v.val) {
            if (p.key.equals(index)) {
                return v.val[i].val = obj;
            }
        }
        v.val ~= Pair(index, obj);
        return obj;
    }
    //auto cat(Map a) { return val.append(a.val); }

    bool toBool(Dict v) { return v.val.length != 0; }
    DictIter Iter(Dict v) { return DictIter(v); }
}
struct DictIter {
    Dict.Pair* beg;
    Dict.Pair* end;
    Dict.Pair* ptr;
    this(Dict m) {
        beg = ptr = m.val.ptr;
        end = beg + m.val.length;
    }
static:
    tsstring type() { return "list_iterator"; }
    auto Iter(DictIter v) { return v; }
    Obj  Val(DictIter v) { return v.ptr.val; }
    Obj  Index(DictIter v) { return v.ptr.key; }
    bool next(DictIter* v) { return ++v.ptr < v.end; }
}
