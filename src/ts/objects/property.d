module ts.objects.property;

import ts.objects.obj;
import stdd.format;

import com.log;
struct Property {
    Obj get = null;
    Obj set = null;
    this(Obj get, Obj set) {
        this.get = get;
        this.set = set;
    }
    string toString() {
        return format!"(get: %s, set: %s)"(get is null? "null":get.toStr,
                                           set is null? "null":set.toStr);
    }
    Obj callGet(Pos p, Env e) {
        if (!get)
            throw new RuntimeException(p, "property doesn't have a getter");
        return get.call(p, e);
    }
    Obj callSet(Pos p, Env e, Obj val) {
        if (!set)
            throw new RuntimeException(p, "property doesn't have a setter");

        return set.call(p, e, val);
    }
    Obj callGetMember(Pos p, Env e, Obj self) {
        if (!get)
            throw new RuntimeException(p, "property doesn't have a getter");
        return get.call(p, e, self);
    }
    Obj callSetMember(Pos p, Env e, Obj self, Obj val) {
        if (!set)
            throw new RuntimeException(p, "property doesn't have a setter");

        return set.call(p, e, self, val);
    }


    static tsstring type() { return "property"; }
}

Obj assignSetter(Obj[] arr, size_t index, Obj val) {
    Property* p;
    assert(index < arr.length);
    if (arr[index] !is null && (p = arr[index].peek!Property) !is null) {
        return p.set = val;
    }
    return arr[index] = objProperty(null, val);
}
Obj assignSetter(Index)(Obj[Index] arr, Index index, Obj val) {
    Property* p;
    pragma(msg, format!("assign setter ")());

    Obj* ptr = index in arr;
    if (ptr !is null && (p = ptr.peek!Property) !is null) {
        tslog("<<is ss");
        return p.set = val;
    }
    tslog("<<is new");
    return arr[index] = objProperty(null, val);
}

Obj assignGetter(Obj[] arr, size_t index, Obj val) {
    assert(index < arr.length);
    tslog!"getter on [%s] , %s"(index, arr.length);
    if (arr[index] !is null) {
        Property* p = arr[index].peek!Property;
        if (p !is null) {
            return p.get = val;
        }
    }
    return arr[index] = objProperty(val, null);
}
Obj assignGetter(Index)(Obj[Index] arr, Index index, Obj val) {
    Property* p;
    Obj* ptr = index in arr;
    if (ptr !is null && (p = ptr.peek!Property) !is null) {
        return p.get = val;
    }
    return arr[index] = objProperty(val, null);
}
Obj assignFuncType(FuncType ft, Index)(Obj[Index] arr, Index index, Obj val) {
    static if (ft == FuncType.Default)
        return arr[index] = val;
    else static if (ft == FuncType.Setter) {
        return assignSetter(arr, index, val);
    }
    else
        return assignGetter(arr, index, val);
}
