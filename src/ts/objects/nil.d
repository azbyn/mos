module ts.objects.nil;

import ts.objects.obj;

struct Nil {

static:
    tsstring type() { return "nil"; }
    tsstring toString(Nil t) { return "nil"; }
    bool toBool(Nil t) { return false; }
    bool opEq(Nil a, Obj b) { return b.isNil(); }
    bool opEqR(Nil a, Obj b) { return b.isNil(); }
}
