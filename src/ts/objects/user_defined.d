module ts.objects.user_defined;
import ts.objects.obj;


struct UserDefined {
    tsstring name;
    Obj base;

    static tsstring type() { return "__user_defined__"; }
    static Obj Base(UserDefined* v) { return v.base; }
}
