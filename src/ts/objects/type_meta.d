module ts.objects.type_meta;

import ts.objects;
import ts.misc : tsformat;

class TypeException : TSException {
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        super(pos, msg, file, line);
    }
}

__gshared private {
    Obj defaultToBool;
    Obj defaultOpEquals;
}
struct TypeMeta {
    tsstring name;
    Obj ctor;
    Obj[tsstring] members;
    alias Creator = Obj delegate(Pos p, Env e);
    Creator creator;
    static void init() {
        defaultToBool = objBIFunction((Pos p, Env e, Obj[] a) => objBool(true));
        defaultOpEquals = objBIFunction((Pos p, Env e, Obj[] a) => objBool(false));
    }

    private this(tsstring name, Creator c, Obj toStr) {
        this.name = name;
        this.creator = c;
        members["toString"] = toStr;
        members["toBool"] = defaultToBool;
        members["opEquals"] = defaultOpEquals;
    }

    this(tsstring name) {
        this(name, (p, e) => objUserDefined(name, nil),
             objBIFunction((Pos p, Env e, Obj[] a) => objString(a[0].type())));
    }
    static TypeMeta __mk(tsstring name, Creator c)() {
        return TypeMeta(name, c, objBIFunction((Pos p, Env e, Obj[] a) => objString(name)));
    }
    static TypeMeta __mk(T)() {
        return __mk!(T.type(), (p,e) => new Obj(T()));
    }


    Obj construct(Pos p, Env e, Obj[] a...) {
        import stdd.array;
        import stdd.format;

        if (ctor is null)
            throw new TypeException(p, format!"Type '%s' doesn't have a constructor"(name));
        Obj obj = creator(p, e);
        Obj[] args = uninitializedArray!(Obj[])(a.length + 1);
        args[0] = obj;
        args[1 .. $] = a[];
        ctor.call(p, e, args);
        return obj;
    }


static:
    //super meta
    TypeMeta typeMeta;
    tsstring type() {
        return "__type_meta__";
    }

    tsstring toString(TypeMeta t) {
        return tsformat!"__type_meta@%s__"(t.name);
    }
    /*Obj opCall(Pos p, Env e, Type_ t, Obj[] args) {
        return t.callCtor(p,e,args);
        }*/
    Obj opFwd(Pos p, Env e, TypeMeta* t, tsstring m) {
        return t.members[m];
    }

    Obj opFwdSet(Pos p, Env e, TypeMeta* t, tsstring m, Obj val) {
        return t.members[m] = val;
    }
}
