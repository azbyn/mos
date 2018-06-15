module ts.objects.user_defined;
import ts.objects.obj;

mixin TSModule!(ts.objects.user_defined);

@tsexport struct UserDefined {
    //tsstring name;
    Obj base;

static:
    //TypeMeta typeMeta;
    enum tsstring type = "__user_defined__";
    @tsexport Obj Base(UserDefined* v) { return v.base; }
}
