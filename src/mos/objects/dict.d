module mos.objects.dict;

import mos.objects.obj;
import mos.ast.token;
import stdd.conv;
import stdd.format;
import mos.misc;
import mos.ast.token;
import mos.runtime.env;

mixin MOSModule!(mos.objects.dict);

import com.log;

@mosexport struct Dict {
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
    mixin MOSType!"dict";
    @mosexport {
        void ctor(Dict v) { v.val = []; }
        mosstring toString(Pos p, Env e, Dict v) {
            mosstring res = "{";
            foreach (x; v.val)
                res ~= mosformat!"%s: %s, "(x.key.toStr(p, e), x.val.toStr(p, e));
            return res ~ "}";
        }

        @mosget mosint Size(Dict v) { return v.val.length; }
        Obj opIndex(Pos pos, Env env, Dict* v, Obj index) {
            foreach (i, p; v.val) {
                if (p.key.equals(pos, env, index)) {
                    return v.val[i].val;
                }
            }
            throw new RuntimeException(pos, format!"Key '%s' not found"(index.toStr(pos, env)));
        }
        Obj opIndexSet(Pos pos, Env env, Dict* v, Obj index, Obj obj) {
            foreach (i, p; v.val) {
                if (p.key.equals(pos, env, index)) {
                    return v.val[i].val = obj;
                }
            }
            v.val ~= Pair(index, obj);
            return obj;
        }
        //auto cat(Map a) { return val.append(a.val); }

        bool toBool(Dict v) { return v.val.length != 0; }
        Dict dup(Dict v) { return Dict(v.val.dup()); }
        bool opEquals(Pos p, Env e, Dict v, Obj oth) {
            return oth.visitO!(
                (Dict o) {
                    if (o.val.length != v.val.length) return false;
                    Pair* i1 = v.val.ptr;
                    Pair* i2 = o.val.ptr;
                    Pair* end = v.val.ptr + v.val.length;
                    while (i1 != end) {
                        if (!i1.key.equals(p,e, i2.key)|| !i1.val.equals(p, e, i2.val))
                            return false;
                        ++i1;
                        ++i2;
                    }
                    return true;
                },
                () => false);
        }

        struct Iterator {
            Dict.Pair* beg;
            Dict.Pair* end;
            Dict.Pair* ptr;
            this(Dict m) {
                beg = ptr = m.val.ptr;
                end = beg + m.val.length;
            }
        static:
            mixin MOSType!"dict_iterator";
            @mosexport {
                @mosget auto Iter(Iterator v) { return v; }
                @mosget Obj  Val(Iterator v) { return v.ptr.val; }
                @mosget Obj  Index(Iterator v) { return v.ptr.key; }
                bool next(Iterator* v) { return ++v.ptr < v.end; }
            }
        }
        @mosget Iterator Iter(Dict v) { return Iterator(v); }
    }
}
