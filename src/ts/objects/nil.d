module ts.objects.nil;

import ts.objects.obj;

mixin TSModule!(ts.objects.nil);

@tsexport struct Nil {
static:
    mixin TSType!"nil";
    @tsexport {
        tsstring toString(Nil t) { return "nil"; }
        bool toBool(Nil t) { return false; }
        bool opEquals(Nil a, Obj b) { return b.isNil(); }
        bool opEqualsR(Nil a, Obj b) { return b.isNil(); }
    }
}
