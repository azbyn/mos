module ts.runtime.env;

import ts.objects.obj;
import ts.ir.symbol_table;
import ts.ir.compiler : OffsetVal;
import stdd.array;

class Env {
    ushort offset;
    Obj[] objs;
    Obj*[OffsetVal] captures;
    this(Env parent, SymbolTable st, Obj*[OffsetVal] captures) {
        this(st);
        if (parent !is null)
            this.captures = parent.captures;
        if (captures !is null) {
            foreach (k, o; captures) {
                this.captures[k] = o;
            }
        }
    }
    this(SymbolTable st) {
        offset = st.offset;
        objs = uninitializedArray!(Obj[])(st.names.length);
    }
    Obj get(T)(T val) { return get(OffsetVal(val.offset, val.val)); }
    Obj get(OffsetVal val){
        if (val.offset == offset)
            return objs[val.val];
        if (auto o = captures.get(val, null))
            return *o;
        assert(0);
    }
    Obj* getPtr(OffsetVal val) {
        if (val.offset == offset)
            return &objs[val.val];
        if (auto o = captures.get(val, null))
            return o;
        assert(0);

    }
    Obj set(T)(T val, Obj o) { return set(OffsetVal(val.offset, val.val), o); }
    Obj set(OffsetVal val, Obj o) {
        if (val.offset == offset) {
            return objs[val.val] = o;
        }
        if (val in captures) {
            return *captures[val] = o;
        }
        assert(0);
    }
}
