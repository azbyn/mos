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

private alias Creator = Obj delegate() @system;
TypeMeta makeTypeMeta(tsstring name, Creator c)() {
    return TypeMeta(name, c, obj!BIFunction((Pos p, Env e, Obj[] a) => obj!String(name)));
}
TypeMeta makeTypeMetaF(tsstring name, Obj function() @system c)() {
    import stdd.functional;
    return TypeMeta(name, c.toDelegate(), obj!BIFunction((Pos p, Env e, Obj[] a) => obj!String(name)));
}

TypeMeta makeTypeMeta(T)() {
    //tslog!"_MAKE_TYPE_META '%s'"(T.type);
    return makeTypeMetaF!(T.type, () => new Obj(&T.typeMeta, T()));
}
@tsexport struct TypeMeta {
    tsstring name;
    Obj ctor;
    Obj[tsstring] instance;
    Obj[tsstring] statics;
    Creator creator;
    static void init() {
        defaultToBool = MethodMaker.mk((Obj o)=>obj!BIFunction((Pos p, Env e, Obj[] a) => obj!Bool(true)));
        defaultOpEquals = MethodMaker.mk((Obj o)=>obj!BIFunction((Pos p, Env e, Obj[] a) => obj!Bool(false)));
    }

    private this(tsstring name, Creator c, Obj delegate(Obj) toStr) {
        this.name = name;
        this.creator = c;
        instance["toString"] = obj!MethodMaker(toStr);
        instance["toBool"] = defaultToBool;
        instance["opEquals"] = defaultOpEquals;
    }
    private this(tsstring name, Creator c, Obj toStr) {
        this.name = name;
        this.creator = c;
        instance["toString"] = obj!MethodMaker((Obj o)=> toStr);
        instance["toBool"] = defaultToBool;
        instance["opEquals"] = defaultOpEquals;
    }


    this(tsstring name) {
        this(name, () => new Obj(&this, UserDefined(instance)),
             (Obj o)=> obj!BIClosure((Pos p, Env e, Obj[] a) => obj!String(o.typestr)));
    }

    Obj construct(Pos p, Env e, Obj[] args...) {
        import stdd.array;

        if (ctor is null)
            throw new TypeException(p, format!"Type '%s' doesn't have a constructor"(name));
        Obj obj = creator();
        ctor.peek!MethodMaker().callThis(obj).call(p, e, args);
        return obj;
    }

    Obj getMember(Obj this_, Pos p, Env e, tsstring mem) {
        if (auto ud = this_.peek!UserDefined) {
            return ud.get(this_, p, e, mem);
        }
        //dfmt off
        return getMember2(p, e, mem, "opFwd",
                          (Obj f) => f.visitO!(
                              (Property pr) => pr.callGet(p, e),
                              (PropertyMember pm) => pm.callGet(p, e, this_),
                              (MethodMaker m) => m.callThis(this_),
                              () => f),
                          (Obj f) => f.visitO!(
                              (MethodMaker m) => m.callThis(this_),
                              () => f).call(p, e, obj!String(mem)));
        //dfmt on
    }
    Obj setMember(Obj this_, Pos p, Env e, tsstring mem, Obj val) {
        if (auto ud = this_.peek!UserDefined) {
            return ud.set(this_, p, e, mem, val);
        }

        Obj setterErr(Obj o) {
            throw new RuntimeException(p, format!"%s.%s doesn't have a setter"(this_.typestr, mem));
        }
        return getMember2(p, e, mem, "opFwdSet",
                          (Obj f) =>f.visitO!(
                              (Property pr) => pr.callSet(p, e, val),
                              (PropertyMember pm) => pm.callSet(p, e, this_, val),
                              //(BIMethodMaker m) => m.callThis(a).setMember(p, e, mem, val),
                              () => setterErr(f)),
                          (Obj f) => f.visitO!(
                              (MethodMaker m) => m.callThis(this_),
                              () => f).call(p, e,  obj!String(mem), val));
    }

    /*
    private Obj getMember_(Pos p, Env e, tsstring s) {
        auto m = instance.get(s, null);
        if (m is null)
            throw new TypeException(p, format!"Type '%s' doesn't have member '%s'"(this, s));
        return m;
        }*/

    private auto getMember2(F1, F2)(Pos p, Env e, tsstring s1, tsstring s2, F1 f1, F2 f2,
                            string file =__FILE__, size_t line = __LINE__) {
        if (auto m = tryMember(s1)) {
            return f1(m);
        }
        if (auto m = tryMember(s2)) {
            return f2(m);
        }
        if (auto s = statics.get(s1, null)) {
            return f1(s);
        }
        throw new TypeException(p, format!"Type '%s' doesn't contain '%s'"(name, s1), file, line);
    }

    Obj tryMember(tsstring s) {
        return instance.get(s, null);
    }
    Obj getStatic(Pos p, Env e, tsstring s) {
        Obj* x = s in statics;
        if (x is null)
            throw new RuntimeException(p, format!"type '%s' doesn't contain '%s'"(name, s));
        Property* prop = x.val.peek!Property;
        if (prop !is null)
            return prop.callGet(p, e);

        return *x;
    }
    Obj setStatic(Pos p, Env e, tsstring m, Obj val) {
        import ts.objects.property;
        Obj* x = m in statics;
        if (x is null)
            throw new RuntimeException(p, format!"type '%s' doesn't contain '%s'"(name, m));
        Property* prop = x.val.peek!Property;
        if (prop !is null)
            return prop.callSet(p, e, val);
        return *x = val;
    }

static:
    mixin TSType!"__type_meta__";
    @tsexport {
        tsstring toString(TypeMeta t) {
            return tsformat!"__type_meta@%s__"(t.name);
        }
        /*Obj opCall(Pos p, Env e, Type_ t, Obj[] args) {
            return t.callCtor(p,e,args);
            }*/
        Obj opFwd(Pos p, Env e, TypeMeta* t, tsstring m) {
            return t.getStatic(p, e, m);
        }

        Obj opFwdSet(Pos p, Env e, TypeMeta* t, tsstring m, Obj val) {
            return t.setStatic(p, e, m, val);
        }
    }
}
