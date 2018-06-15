module ts.objects.type_meta;

import ts.objects;
import ts.misc : tsformat;
import stdd.format : format;

mixin TSModule!(ts.objects.type_meta);


class TypeException : TSException {
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        super(pos, msg, file, line);
    }
}

__gshared private {
    Obj defaultToBool;
    Obj defaultOpEquals;
}

private alias Creator = Obj delegate(Pos p, Env e);
TypeMeta makeTypeMeta(tsstring name, Creator c)() {
    return TypeMeta(name, c, obj!BIFunction((Pos p, Env e, Obj[] a) => obj!String(name)));
}
TypeMeta makeTypeMeta(T)() {
    //tslog!"_MAKE_TYPE_META '%s'"(T.type);
    return makeTypeMeta!(T.type, (p,e) => new Obj(&T.typeMeta, T()));
}
@tsexport struct TypeMeta {
    tsstring name;
    Obj ctor;
    Obj[tsstring] members;
    Creator creator;
    static void init() {
        defaultToBool = obj!BIFunction((Pos p, Env e, Obj[] a) => obj!Bool(true));
        defaultOpEquals = obj!BIFunction((Pos p, Env e, Obj[] a) => obj!Bool(false));
    }

    private this(tsstring name, Creator c, Obj toStr) {
        this.name = name;
        this.creator = c;
        members["toString"] = toStr;
        members["toBool"] = defaultToBool;
        members["opEquals"] = defaultOpEquals;
    }

    this(tsstring name) {
        this(name, (p, e) => new Obj(&this, UserDefined(nil)),
             obj!BIFunction((Pos p, Env e, Obj[] a) => obj!String(a[0].typestr)));
    }

    Obj construct(Pos p, Env e, Obj[] a...) {
        import stdd.array;

        if (ctor is null)
            throw new TypeException(p, format!"Type '%s' doesn't have a constructor"(name));
        Obj obj = creator(p, e);
        Obj[] args = uninitializedArray!(Obj[])(a.length + 1);
        args[0] = obj;
        args[1 .. $] = a[];
        ctor.call(p, e, args);
        return obj;
    }

    Obj getMember(Pos p, Env e, Obj a, tsstring val, string file =__FILE__, size_t line = __LINE__) {
        //dfmt off
        return getMember2(p, e, val, "opFwd",
                          (Obj f) => f.visitO!(
                              (Property pr) => pr.callGet(p, e),
                              (PropertyMember pm) => pm.callGet(p, e, a),
                              (BIMethodMaker m) => m.callThis(a),
                              () => f),
                          (Obj f) => f.visitO!(
                              (BIMethodMaker m) => m.callThis(a),
                              () => f).call(p, e, a, obj!String(val)));
        //dfmt on
    }
    Obj setMember(Pos p, Env e, Obj a, tsstring mem, Obj val) {
        Obj setterErr(Obj o) {
            throw new RuntimeException(p, format!"%s.%s doesn't have a setter"(a.typestr, mem));
        }
        return getMember2(p, e, mem, "opFwdSet",
                          (Obj f) =>f.visitO!(
                              (Property pr) => pr.callSet(p, e, val),
                              (PropertyMember pm) => pm.callSet(p, e, a, val),
                              (BIMethodMaker m) => m.callThis(a).setMember(p, e, mem, val),
                              () => setterErr(f)),
                          (Obj f) => f.visitO!(
                              (BIMethodMaker m) => m.callThis(a),
                              () => f).call(p, e, a, obj!String(mem), val));
    }

    Obj getMember_(Pos p, Env e, Obj o, tsstring s) {
        auto m = members.get(s, null);
        if (m is null)
            throw new TypeException(p, format!"Type '%s' doesn't have member '%s'"(o.typestr, s));
        return m;
    }

    auto getMember2(F1, F2)(Pos p, Env e, tsstring s1, tsstring s2, F1 f1, F2 f2,
                            string file =__FILE__, size_t line = __LINE__) {
        if (auto m = tryMember(s1)) {
            return f1(m);
        }
        if (auto m = tryMember(s2)) {
            return f2(m);
        }
        throw new TypeException(p,
                                format!"Type '%s' doesn't have neither '%s', nor '%s'"(name, s1, s2), file, line);
    }

    Obj tryMember(tsstring s) {
        return members.get(s, null);
    }



static:
    //super meta
    __gshared TypeMeta typeMeta;
    enum tsstring type = "__type_meta__";
    @tsexport {
        tsstring toString(TypeMeta t) {
            return tsformat!"__type_meta@%s__"(t.name);
        }
        /*Obj opCall(Pos p, Env e, Type_ t, Obj[] args) {
            return t.callCtor(p,e,args);
            }*/
        Obj opFwd(Pos p, Env e, TypeMeta* t, tsstring m) {
            Obj* x = m in t.members;
            if (x is null)
                throw new RuntimeException(p, format!"type '%s' doesn't contain '%s'"(t.name, m));
            return *x;
        }

        Obj opFwdSet(Pos p, Env e, TypeMeta* t, tsstring m, Obj val) {
            import ts.objects.property;
            Obj* x = m in t.members;
            if (x is null)
                throw new RuntimeException(p, format!"module '%s' doesn't contain '%s'"(t.name, m));
            Property* prop = x.val.peek!Property;
            if (prop !is null)
                return prop.callSet(p, e, val);
            return *x = val;
            //return t.members[m] = val;
        }
    }
}
