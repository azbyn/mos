module ts.ir.symbol_table;

import stdd.algorithm;
import stdd.array;
import stdd.format;
import ts.ir.block_manager;
import ts.ir.block;
import ts.ast.token;
import ts.ir.compiler : OffsetVal;

import com.log;

class SymbolTable {
    OffsetVal[] captures;
    //SymbolTable parent;
    tsstring[] names;
    ushort offset;
    //SymbolTable[] children;

    this(tsstring[] names) {
        offset = 0;
        this.names = names;
    }

    this(BlockManager man, OffsetVal[] captures = null) {
        this.captures = captures;
        offset = man.addST(this);
    }

    this(BlockManager man, OffsetVal[] captures, tsstring[] args, out OffsetVal[] outArgs) {
        this(man, captures);
        names = args;
        outArgs = uninitializedArray!(OffsetVal[])(args.length);
        foreach (i, a; args) {
            outArgs[i] = OffsetVal(offset, i);
        }
    }

    OffsetVal get(Pos pos, BlockManager man, tsstring name) {
        OffsetVal r;
        if (!getName(man, name, r)) {
            names ~= name;
            return OffsetVal(offset, cast(uint) names.length - 1);
        }
        return r;
    }
    bool getName(BlockManager man, tsstring name, out OffsetVal res) {
        foreach (i, n; names) {
            if (n == name) {
                res = OffsetVal(offset, i);
                return true;
            }
        }
        if (captures is null) return false;
        foreach (v; captures) {
            if (getStr(man, v) == name) {
                res = v;
                return true;
            }
        }
        /*
        if (parent !is null) {
            return parent.getName(name, res);
            }*/
        return false;
    }
/*
    SymbolTable child(BlockManager man) {
        return new SymbolTable(man, this);
        }*/

    tsstring getStr(T)(BlockManager man, T t) {
        import ts.misc;
        /*
        if (man.tables is null) {
            if (t.offset != 0)
                return format!"<INVALID-OFF %s-%s>"(t.offset, t.val);
            if (t.val >= names.length)
                return format!"<OUT-OF-RANGE %s>"(t.val);
            //assert(t.offset == 0, format!"expected offset 0, got %d"(t.offset));
            return names[t.val];
            }*/
        assert(t.offset < man.tables.length,
                format!"offset %d out of range (%s)"(t.offset, man.tables.length));
        auto tbl = man.tables[t.offset].names;
        if (t.val >= tbl.length)
            return tsformat!"<INVALID %s-%s>"(t.offset, t.val);
        //assert(0, format!"val o:%d v:%d out of range (%s)"(t.offset, t.val, tbl.length));
        return tbl[t.val];
    }
}
