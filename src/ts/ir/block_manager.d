module ts.ir.block_manager;

import ts.objects.obj;
import ts.ir.block;
import ts.ir.symbol_table;
import ts.ir.lib;
import ts.ir.compiler;
import ts.misc;

struct ModuleMaker {
    bool isType;
    tsstring name;
    OffsetVal ov;
    OffsetVal[] captures;
    Block[tsstring] members;
    Block[tsstring] methods;
    Block[tsstring] getters;
    Block[tsstring] setters;

    this(bool isType, tsstring name, OffsetVal ov) {
        this.isType = isType;
        this.name = name;
        this.ov = ov;
    }
    tsstring toString(Pos p, Env e) {
        tsstring res = tsformat!"<typeMaker '%s'@%s>\n"(name, ov);
        res ~= "\nmembers:";
        foreach (n, m; members) {
            res ~= tsformat!"\n[%s]: %s"(n, m.toStr(p, e));
        }

        res ~= "\nmethods:";
        foreach (n, m; methods) {
            res ~= tsformat!"\n[%s]: %s"(n, m.toStr(p, e));
        }
        res ~= "\n>getters:";
        foreach (n, m; getters) {
            res ~= tsformat!"\n[%s]: %s"(n, m.toStr(p, e));
        }
        res ~= "\n>setters:";
        foreach (n, m; setters) {
            res ~= tsformat!"\n[%s]: %s"(n, m.toStr(p,e));
        }
        return res ~ "\n</typeMaker>";
    }
}
class BlockManager {
    Obj[] consts;
    Lib lib;
    SymbolTable[] tables;
    tsstring[] strs;
    Block[] blocks;
    ModuleMaker[] modules;
    size_t[] jumpTable;

    @property Block mainBlock() { return blocks[0]; }

    this(Lib lib, out Block mainBlock) {
        this.lib = lib;
        consts ~= nil;
        mainBlock = new Block(this);
        blocks ~= mainBlock;
    }

    ushort addST(SymbolTable st){
        tables ~= st;
        return cast(ushort) (tables.length - 1);
    }

    size_t addJump(size_t pos = -1) {
        jumpTable ~= pos;
        return jumpTable.length - 1;
    }
    override string toString() {
        import stdd.format;
        assert(0, format!"please use toStr %s, %s"(__FILE__, __LINE__));
    }
    tsstring toStr_unsafe() { return toStr(Pos(-1), null); }
    tsstring toStr(Pos p, Env e) {
        return mainBlock.toStr(p, e);
    }
}
