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

static:
    TypeMeta typeMeta;
    tsstring type() { return "property"; }
}

Obj assignSetter(ref Obj[] arr, size_t index, Obj val) {
    Property* p;
    assert(index < arr.length);
    if (arr[index] !is null && (p = arr[index].peek!Property) !is null) {
        return p.set = val;
    }
    return arr[index] = objProperty(null, val);
}
Obj assignSetter(Index)(ref Obj[Index] arr, Index index, Obj val) {
    Property* p;
    Obj* ptr = index in arr;
    if (ptr !is null && (p = ptr.peek!Property) !is null) {
        return p.set = val;
    }
    return arr[index] = objProperty(null, val);
}

Obj assignGetter(ref Obj[] arr, size_t index, Obj val) {
    assert(index < arr.length);
    //tslog!"getter on [%s] , %s"(index, arr.length);
    if (arr[index] !is null) {
        Property* p = arr[index].peek!Property;
        if (p !is null) {
            return p.get = val;
        }
    }
    return arr[index] = objProperty(val, null);
}
Obj assignGetter(Index)(ref Obj[Index] arr, Index index, Obj val) {
    Property* p;
    Obj* ptr = index in arr;
    if (ptr !is null && (p = ptr.peek!Property) !is null) {
        return p.get = val;
    }
    return arr[index] = objProperty(val, null);
}
Obj assignFuncType(FuncType ft, Index)(ref Obj[Index] arr, Index index, Obj val) {
    static if (ft == FuncType.Getter) {
        return assignGetter(arr, index, val);
    }
    else static if (ft == FuncType.Setter) {
        return assignSetter(arr, index, val);
    }
    else {
        return arr[index] = val;
    }
}
