module ts.ir.block_manager;

import ts.objects.obj;
import ts.ir.block;
import ts.ir.symbol_table;
import ts.ir.lib;
import ts.ir.compiler;
import ts.misc;
import stdd.format : format;

struct ModuleMaker {
    bool isType;
    tsstring name;
    uint[] captures;
    Block[tsstring] members;
    Block[tsstring] methods;
    Block[tsstring] getters;
    Block[tsstring] setters;

    this(bool isType, tsstring name) {
        this.isType = isType;
        this.name = name;
    }
    tsstring toString(Pos p, Env e) {
        tsstring res = tsformat!"<typeMaker '%s'>\n"(name);
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
    //SymbolTable[] tables;
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
    uint[] getBulk(tsstring[] caps) {
        import stdd.array;
        auto res = uninitializedArray!(uint[])(caps.length);
        foreach (i, c; caps) {
            res[i] = getIndex(c);
        }
        return res;
    }
    uint[] addBulk(tsstring[] caps) {
        import stdd.array;
        auto res = uninitializedArray!(uint[])(caps.length);
        foreach (i, c; caps) {
            res[i] = addStr(c);
        }
        return res;
    }

    tsstring getStr(uint t) {
        return strs[t];
    }
    bool tryGetIndex(tsstring str, out uint res) {
        foreach (i, s; strs){
            if (s == str) {
                res =  cast(uint)i;
                return true;
            }
        }
        return false;
    }
    uint getIndex(tsstring str, string file = __FILE__, size_t line = __LINE__) {
        foreach (i, s; strs)
            if (s == str) return cast(uint) i;
        throw new Exception(format!"invalid getIndex %s"(str), file, line);
    }
    uint addStr(tsstring str) {
        foreach (i, s; strs)
            if (s == str) return cast(uint) i;
        strs ~= str;
        return cast(uint) strs.length - 1;
    }
/*
    ushort addST(SymbolTable st){
        tables ~= st;
        return cast(ushort) (tables.length - 1);
        }*/

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
