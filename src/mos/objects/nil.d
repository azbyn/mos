module mos.objects.nil;

import mos.objects.obj;

mixin MOSModule!(mos.objects.nil);

@mosexport struct Nil {
static:
    mixin MOSType!"nil";
    @mosexport {
        mosstring toString(Nil t) { return "nil"; }
        bool toBool(Nil t) { return false; }
        bool opEquals(Nil a, Obj b) { return b.isNil(); }
        bool opEqualsR(Nil a, Obj b) { return b.isNil(); }
    }
}
