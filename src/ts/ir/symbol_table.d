module ts.ir.symbol_table;

import stdd.algorithm;
import stdd.array;
import stdd.format;
import ts.ir.block_manager;
import ts.ir.block;
import ts.ast.token;

import com.log;

class SymbolTable {
    uint[] captures;
    BlockManager man;
    uint[] symbols;
    //only use uints

    //tsstring[] imports;//???

    this(uint[] symbols) {
        this.symbols = symbols;
    }

    this(BlockManager man, uint[] captures = null, uint[] imports = null) {
        this.captures = captures;
        this.man = man;
        //this.imports = imports;
        //offset = man.addST(this);
    }
    this(BlockManager man, uint[] captures, uint[] args, uint[] imports) {
        this(man, captures, imports);
        symbols = args;
    }
    private bool contains(uint val) {
        foreach (i, n; symbols)
            if (n == val)
                return true;
        return false;
    }
    uint addStr(tsstring name) {
        tslog!"adding %s"(name);
        auto i = man.addStr(name);
        if (!contains(i))
            symbols ~= i;
        return i;
    }
    bool getName(tsstring name) {
        uint index;
        if (!man.tryGetIndex(name, index))
            return false;
        if (contains(index))
            return true;
        foreach (v; captures) {
            if (v == index) {
                return true;
            }
        }
        return false;
    }
}
