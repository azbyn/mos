module ts.ir.block;

import ts.ast.token;
import ts.ir.compiler;
import ts.ir.symbol_table;
import ts.ir.lib;
import ts.ir.block_manager;
import ts.objects.obj;
import ts.misc;
import stdd.array;
import stdd.format;
import stdd.algorithm;

class IRException : TSException {
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        super(pos, msg, file, line);
    }
}

class Block {
    OP[] ops;
    private SymbolTable _st;
    @property SymbolTable st() {
        return _st;
    }

    BlockManager man;
    uint[] args;
    @property Lib lib() {
        return man.lib;
    }
    @property uint[] captures() {
        return _st.captures;
    }

    this(BlockManager man) {
        this.man = man;
        //man.blocks ~= this;
        _st = new SymbolTable(man);
    }

    this(BlockManager man, uint[] args, uint[] captures) {
        this.man = man;
        //man.blocks ~= this;
        this.args = args;
        _st = new SymbolTable(man, captures, args);
    }

    void addVal(Pos pos, OPCode code, uint val) {
        ops ~= OP(pos, code, val);
    }
    void addClosureOrFunc(Pos pos, Block block) {
        if (block.captures.length == 0)
            addConst(pos, objFunction(block));
        else
            addClosure(pos, block);
    }

    void addClosure(Pos pos, Block bl) {
        man.blocks ~= bl;
        addVal(pos, OPCode.MakeClosure, man.blocks.length - 1);
    }
    void addModule(Pos pos, ModuleMaker mm) {
        man.modules ~= mm;
        addVal(pos, OPCode.MakeModule, man.modules.length - 1);
    }

    void add(Pos pos, OPCode op) {
        addVal(pos, op, 0);
    }


    void addVal(Pos pos, OPCode op, ulong val) {
        addVal(pos, op, cast(uint) val);
    }
    void addStr(Pos pos, OPCode op, tsstring mem) {
        addVal(pos, op, man.addStr(mem));
    }
    void addVariable(Pos pos, tsstring var, string file = __FILE__, size_t line = __LINE__) {
        if (var == "_")
            throw new IRException(pos, "Invalid name '_'");
        size_t lres;
        if (st.getName(var)) {
            addVal(pos, OPCode.LoadVal, man.addStr(var));
        }
        else if (lib.get(var, lres)) {
            addVal(pos, OPCode.LoadLib, lres);
        }
        else
            throw new IRException(pos, format!"'%s' not defined"(var), file, line);
    }

    void addConst(Pos pos, Obj val) {
        auto getIndex() {
            foreach (i, o; man.consts) {
                if (o == val)
                    return i;
            }
            man.consts ~= val;
            return man.consts.length - 1;
        }

        addVal(pos, OPCode.LoadConst, getIndex());
    }
    void addAssign(Pos pos, tsstring var) {
        if (var == "_")
            return;
        addVal(pos, OPCode.Assign, st.addStr(var));
    }
    void addSetterDef(Pos pos, tsstring var) {
        if (var == "_")
            return;
        addVal(pos, OPCode.SetterDef, st.addStr(var));
    }
    void addGetterDef(Pos pos, tsstring var) {
        if (var == "_")
            return;
        addVal(pos, OPCode.GetterDef, st.addStr(var));
    }
    void addPropDef(Pos pos, tsstring var) {
        if (var == "_")
            return;
        addVal(pos, OPCode.PropDef, st.addStr(var));
    }


    tsstring getStr(size_t i) {
        assert(i < man.strs.length, format!"str %s out of range (%s)"(i, man.strs.length));
        return man.strs[i];
    }
    private int tempCounter = -1;
    auto addAssignTemp(Pos pos) {
        auto v = man.addStr(tsformat!"_t%d"(++tempCounter));
        addVal(pos, OPCode.Assign, v);
        return v;
    }
    Obj getConst(size_t i) {
        return man.consts[i];
    }

    void addNil(Pos pos) {
        addVal(pos, OPCode.LoadConst, 0);
    }

    size_t addJmp(Pos pos, OPCode op) {
        auto j = man.addJump();
        addVal(pos, op, j);
        return j;
    }
    size_t reserveJmp() {
        return man.addJump();
    }

    size_t here() {
        return man.addJump(ops.length);
    }
    size_t getJmp(size_t jmp) {
        return man.jumpTable[jmp];
    }

    void setJmpHere(size_t jmp) {
        man.jumpTable[jmp] = ops.length;
    }

    override string toString() {
        assert(0, "!!!!!please use toStr");
    }
    tsstring toStr(Pos p, Env e) {
        tsstring r = "";
        if (args !is null) {
            r ~= "\nargs: ";
            foreach (a; args) {
                r ~= tsformat!"\n%s: %s"(a, man.getStr(a));
            }
        }
        if (captures !is null) {
            r ~= "\ncaptures: ";
            foreach (a; captures) {
                r ~= tsformat!"\ncap:%s"(a);
            }
        }

        tsstring getLabel(ulong pos) {
            tsstring res = "";
            foreach (i, l; man.jumpTable) {
                if (l == pos) { res ~= tsformat!"%4s\n"(tsformat!"L%s:"(i)); }
            }
            return (res.length == 0)? "    ": res[0..$-1];
        }
        foreach (i, o; ops) {
            r ~= tsformat!"\n%s %s "(getLabel(i), o);
            switch (o.code) {
            case OPCode.MakeModule:
                r ~= tsformat!"(%s)"(man.modules[o.val].toStr(p, e));
                break;
            case OPCode.MakeClosure:
                r ~= tsformat!"(%s)"(man.blocks[o.val].toStr(p, e));
                break;
            case OPCode.LoadConst:
                r ~= tsformat!"(%s)"(man.consts[o.val].toStr(p, e));
                break;
            case OPCode.Cmp:
                r ~= tsformat!"(%s)"(symbolicStr(cast(TT) o.val));
                break;
            case OPCode.Binary:
                //case OPCode.MethodCall:
            case OPCode.MemberGet:
            case OPCode.MemberSet:
            case OPCode.LoadVal:
            case OPCode.Assign:
            case OPCode.GetterDef:
            case OPCode.PropDef:
            case OPCode.SetterDef:
                r ~= tsformat!"(%s)"(man.getStr(o.val));
                break;
            case OPCode.LoadLib:
                r ~= tsformat!"(%s)"(lib.getName(o.val));
                break;
            case OPCode.Jmp:
            case OPCode.JmpIfFalseOrPop:
            case OPCode.JmpIfTrueOrPop:
            case OPCode.JmpIfFalsePop:
            case OPCode.JmpIfTruePop:
                r ~= tsformat!"(L%s)"(o.val);
                break;
            default:
                break;
            }
        }
        return r;
    }
}
