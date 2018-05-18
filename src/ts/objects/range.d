module ts.objects.range;

import ts.objects.obj;
import ts.stdlib;

struct Range {
    Obj val;
    Obj end;
    Obj step;
    bool neg;
static:
    void ctor(Pos p, Env e, Range* v, Obj[] args) {
        void init(Obj val, Obj end, Obj step) {
            v.val = val;
            v.end = end;
            v.step = step;
            v.neg = v.step.cmp(p, e, objInt(0)) < 0;
        }
        switch (args.length) {
        case 1:
            init(objInt(0), args[0], objInt(1));
            break;
        case 2:
            init(args[0], args[1], objInt(1));
            break;
        case 3:
            init(args[0], args[1], args[2]);
            break;
        default:
            invalidArgcRange(p, e, 1, 3, args.length);
            break;
        }
    }
    tsstring type() { return "range"; }
    Range Iter(Range v) { return v; }
    Obj  Val(Range v) { return v.val; }
    Obj Index(Range v) { return nil; }
    bool next(Pos p, Env e, Range* v) {
        v.val = v.val.binary!"+"(p, e, v.step);
        auto val = v.val.cmp(p, e, v.end);
        return v.neg ? val > 0 : val < 0;
    }
}
