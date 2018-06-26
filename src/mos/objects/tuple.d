module mos.objects.tuple;

import mos.objects;
import mos.runtime.env;
import mos.ast.token;
import stdd.conv;
import stdd.format;
import stdd.array;

mixin MOSModule!(mos.objects.tuple);

@mosexport struct Tuple {
    Obj[] val;
    this(Obj[] val) {
        this.val = val;
    }
static:
    mixin MOSType!"tuple";
    @mosexport {
        void ctor(Tuple* v) { v.val = []; }
        void ctor(Tuple* v, Tuple o) {
            v.val = o.val;
        }
        mosstring toString(Pos p, Env e, Tuple v) {
            mosstring res = "(";
            foreach (o; v.val)
                res ~= o.toStr(p, e) ~", ";
            return res ~ ")";
        }

        @mosget mosint Size(Tuple v) { return v.val.length; }
        Obj opIndex(Pos pos, Tuple v, mosint i) {
            return v.val[i];
        }

        @mosget Obj Head(Tuple t) { return t.val[0]; }
        @mosget Tuple Tail(Tuple t) { return Tuple(t.val[1..$]); }

        bool toBool(Tuple v) { return v.val.length != 0; }
        Tuple dup(Tuple v) { return Tuple(v.val.dup()); }
        bool opEquals(Pos p, Env e, Tuple v, Obj oth) {
            return oth.visitO!(
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

        struct Iterator {
            Obj* beg;
            Obj* end;
            Obj* ptr;
            this(Tuple l) {
                beg = ptr = l.val.ptr;
                end = beg + l.val.length;
            }
        static:
            mixin MOSType!"tuple_iterator";
            @mosexport {
                @mosget auto  Iter(Iterator v) { return v; }
                @mosget Obj   Val(Iterator v) { return *v.ptr; }
                @mosget mosint Index(Iterator v) { return v.ptr-v.beg; }
                bool next(Iterator* v) { return ++v.ptr < v.end; }
            }
        }
        @mosget Iterator Iter(Tuple v) { return Iterator(v); }
    }
}

