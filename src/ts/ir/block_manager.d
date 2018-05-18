module ts.ir.block_manager;

import ts.objects.obj;
import ts.ir.block;
import ts.ir.symbol_table;
import ts.ir.lib;
import ts.ir.compiler;
import ts.misc;

struct ClosureMaker {
    size_t blockIndex;
    OffsetVal[] captures;
    tsstring toString(BlockManager man) {
        tsstring res = "<closureMaker>\ncaps: \n";
        foreach (c; captures) {
            res ~= tsformat!"%s, %s (%s)\n"(c.offset, c.val, man.tables[0].getStr(man, c));
        }
        res ~= "block:" ~ man.getCMBlock(this).toStr;

        return res ~ "\n</closureMaker>";
    }
}
class BlockManager {
    Obj[] consts;
    Lib lib;
    SymbolTable[] tables;
    tsstring[] strs;
    Block[] blocks;
    ClosureMaker[] closures;
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
    Block getCMBlock(ClosureMaker cm) {
        return blocks[cm.blockIndex];
    }
    Block getCMBlock(size_t index) {
        return getCMBlock(closures[index]);
    }

    size_t addJump(size_t pos = -1) {
        jumpTable ~= pos;
        return jumpTable.length - 1;
    }
    override string toString() {
        import stdd.format;
        assert(0, format!"please use toStr %s, %s"(__FILE__, __LINE__)); }
    tsstring toStr() {
        return mainBlock.toStr();
    }
}
