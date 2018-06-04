module ts.objects.nil;

import ts.objects.obj;

struct Nil {

static:
    tsstring type() { return "nil"; }
    tsstring toString(Nil t) { return "nil"; }
    bool toBool(Nil t) { return false; }
    bool opEquals(Nil a, Obj b) { return b.isNil(); }
    bool opEqualsR(Nil a, Obj b) { return b.isNil(); }
}
