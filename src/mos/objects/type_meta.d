module mos.objects.type_meta;

import mos.objects;
import mos.misc : mosformat;
import stdd.format : format;

mixin MOSModule!(mos.objects.type_meta);


class TypeException : MOSException {
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        super(pos, msg, file, line);
    }
}

__gshared private {
    Obj defaultToBool;
    Obj defaultOpEquals;
}

private alias Creator = Obj delegate() @system;
TypeMeta makeTypeMeta(mosstring name, Creator c)() {
    return new TypeMeta(name, c, obj!BIFunction((Pos p, Env e, Obj[] a) => obj!String(name)));
}
TypeMeta makeTypeMetaF(mosstring name, Obj function() @system c)() {
    import stdd.functional;
    return new TypeMeta(name, c.toDelegate(), obj!BIFunction((Pos p, Env e, Obj[] a) => obj!String(name)));
}

TypeMeta makeTypeMeta(T)() {
    //moslog!"_MAKE_TYPE_META '%s'"(T.type);
    return makeTypeMetaF!(T.type, () => obj!T());
}
private Obj checkProperty(Obj o, Pos p, Env e, Obj this_) {
    return o.visitO!(
        (Property pr) => pr.callGet(p, e).checkProperty(p, e, o),
        (PropertyMember pm) => pm.callGet(p, e, this_).checkProperty(p, e, o),
        (MethodClosureMaker m) => m.callThis(this_).checkProperty(p, e, o),
        (MethodFunctionMaker m) => m.callThis(this_).checkProperty(p, e, o),
        (BIMethodMaker m) => m.callThis(this_).checkProperty(p, e, o),
        () => o);
}
//we make this a class because references of this are needed everywhere
@mosexport class TypeMeta {
    mosstring name;
    @property Obj ctor() { return instance["0ctor"]; }
    @property Obj ctor(Obj val) { return instance["0ctor"] = val; }
    Obj[mosstring] instance;
    Obj[mosstring] statics;
    Creator creator;
    static void init() {
        defaultToBool = BIMethodMaker.mk((Obj o)=>obj!BIFunction((Pos p, Env e, Obj[] a) => obj!Bool(true)));
        defaultOpEquals = BIMethodMaker.mk((Obj o)=>obj!BIFunction((Pos p, Env e, Obj[] a) => obj!Bool(false)));
    }
    this() {}
    private this(mosstring name, Creator c, Obj delegate(Obj) toStr) {
        this.name = name;
        this.creator = c;
        instance["toString"] = obj!BIMethodMaker(toStr);
        instance["toBool"] = defaultToBool;
        instance["opEquals"] = defaultOpEquals;
    }
    private this(mosstring name, Creator c, Obj toStr) {
        this.name = name;
        this.creator = c;
        instance["toString"] = obj!BIMethodMaker((Obj o)=> toStr);
        instance["toBool"] = defaultToBool;
        instance["opEquals"] = defaultOpEquals;
    }
    string dbgString() {
        auto res = format!"type'%s':"(name);
        res ~= "\ninstance:";
        foreach (n,_;instance) {
            res ~= format!"\n  %s"(n);
        }
        res ~= "\nstatic:";
        foreach (n,_;statics) {
            res ~= format!"\n  %s"(n);
        }

        return res~ "\n";
    }

    this(mosstring name) {
        this(name, () => new Obj(this, UserDefined(this)),
             (Obj o)=> obj!BIClosure((Pos p, Env e, Obj[] a) => obj!String(o.typestr)));
    }

    Obj construct(Pos p, Env e, Obj[] args...) {
        import stdd.array;

        if (ctor is null)
            throw new TypeException(p, format!"Type '%s' doesn't have a constructor"(name));
        Obj obj = creator();
        ctor.callThis(p, obj).call(p, e, args);
        return obj;
    }

    Obj getMember(Obj this_, Pos p, Env e, mosstring mem) {
        if (auto ud = this_.peek!UserDefined) {
            return ud.get(this_, p, e, mem);
        }
        //dfmt off
        return getMember2(p, e, mem, "opFwd",
                          (Obj f) => f.checkProperty(p, e, this_)/*.visitO!(
                              (Property pr) => pr.callGet(p, e),
                              (PropertyMember pm) => pm.callGet(p, e, this_),
                              (MethodClosureMaker m) => m.callThis(this_),
                              (MethodFunctionMaker m) => m.callThis(this_),
                              (BIMethodMaker m) => m.callThis(this_),
                              () => f)*/,
                          (Obj f) => f.visitO!(
                              (MethodClosureMaker m) => m.callThis(this_),
                              (MethodFunctionMaker m) => m.callThis(this_),
                              (BIMethodMaker m) => m.callThis(this_),
                              () => f).call(p, e, obj!String(mem)).checkProperty(p, e, f));
        //dfmt on
    }
    Obj setMember(Obj this_, Pos p, Env e, mosstring mem, Obj val) {
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
                              (MethodClosureMaker m) => m.callThis(this_),
                              (MethodFunctionMaker m) => m.callThis(this_),
                              (BIMethodMaker m) => m.callThis(this_),
                              () => f).call(p, e,  obj!String(mem), val));
    }

    /*
    private Obj getMember_(Pos p, Env e, mosstring s) {
        auto m = instance.get(s, null);
        if (m is null)
            throw new TypeException(p, format!"Type '%s' doesn't have member '%s'"(this, s));
        return m;
        }*/

    private auto getMember2(F1, F2)(Pos p, Env e, mosstring s1, mosstring s2, F1 f1, F2 f2,
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

    Obj tryMember(mosstring s) {
        return instance.get(s, null);
    }
    Obj getStatic(Pos p, Env e, mosstring s) {
        Obj* x = s in statics;
        if (x is null)
            throw new RuntimeException(p, format!"type '%s' doesn't static contain '%s'"(name, s));
        Property* prop = x.val.peek!Property;
        if (prop !is null)
            return prop.callGet(p, e);

        return *x;
    }
    Obj setStatic(Pos p, Env e, mosstring m, Obj val) {
        import mos.objects.property;
        Obj* x = m in statics;
        if (x is null)
            throw new RuntimeException(p, format!"type '%s' doesn't contain static '%s'"(name, m));
        Property* prop = x.val.peek!Property;
        if (prop !is null)
            return prop.callSet(p, e, val);
        return *x = val;
    }

static:
    mixin MOSType!"__type_meta__";
    @mosexport {
        mosstring toString(Pos p, Env e, TypeMeta t) {
            return mosformat!"__type_meta@%s__"(t.name);
        }
        /*Obj opCall(Pos p, Env e, Type_ t, Obj[] args) {
            return t.callCtor(p,e,args);
            }*/
        Obj opFwd(Pos p, Env e, TypeMeta* t, mosstring m) {
            return t.getStatic(p, e, m);
        }

        Obj opFwdSet(Pos p, Env e, TypeMeta* t, mosstring m, Obj val) {
            return t.setStatic(p, e, m, val);
        }
    }
}
