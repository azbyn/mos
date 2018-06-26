module mos.ir.block;

import mos.ast.token;
import mos.ir.compiler;
import mos.ir.lib;
import mos.ir.block_manager;
import mos.objects.obj;
import mos.misc;
import stdd.array;
import stdd.format;
import stdd.algorithm;

class IRException : MOSException {
    this(Pos pos, string msg, string file = __FILE__, size_t line = __LINE__) {
        super(pos, msg, file, line);
    }
}

class Block {
    OP[] ops;

    BlockManager man;
    uint[] args;
    bool isVariadic;
    @property Lib lib() {
        return man.lib;
    }
    uint[] captures;

    this(BlockManager man) {
        this.man = man;
        //man.blocks ~= this;
    }

    this(BlockManager man, uint[] args, uint[] captures, bool isVariadic) {
        this.man = man;
        //man.blocks ~= this;
        this.args = args;
        this.isVariadic = isVariadic;
        this.captures = captures;
    }

    void addVal(Pos pos, OPCode code, uint val) {
        ops ~= OP(pos, code, val);
    }
    void addClosureOrFunc(bool isStatic)(Pos pos, Block block) {
        static if (isStatic) {
            if (block.captures.length == 0)
                addConst(pos, obj!StaticFunction(block));
            else
                addClosure(pos, OPCode.MakeStaticClosure, block);
        } else {
            if (block.captures.length == 0)
                addConst(pos, obj!MethodFunctionMaker(block));
            else
                addClosure(pos, OPCode.MakeMethodClosure, block);
        }
    }

    void addClosure(Pos pos, OPCode op, Block bl) {
        man.blocks ~= bl;
        addVal(pos, op, man.blocks.length - 1);
    }

    void add(Pos pos, OPCode op) {
        addVal(pos, op, 0);
    }


    void addVal(Pos pos, OPCode op, ulong val) {
        addVal(pos, op, cast(uint) val);
    }
    void addStr(Pos pos, OPCode op, mosstring mem) {
        addVal(pos, op, man.addStr(mem));
    }
    void addVariable(Pos pos, mosstring var, string file = __FILE__, size_t line = __LINE__) {
        if (var == "_")
            throw new IRException(pos, "Invalid name '_'");
        size_t lres;
        if (man.strs.contains(var)) {
            addVal(pos, OPCode.LoadVal, man.getIndex(var));
        }
        else if (lib.get(var, lres)) {
            addVal(pos, OPCode.LoadLib, lres);
        }
        else {
            addVal(pos, OPCode.LoadVal, man.addStr(var));
        }
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
    void addAssign(Pos pos, mosstring var) {
        if (var == "_")
            return;
        addVal(pos, OPCode.Assign, man.addStr(var));
    }
    void addSetterDef(Pos pos, mosstring var) {
        if (var == "_")
            return;
        addVal(pos, OPCode.SetterDef, man.addStr(var));
    }
    void addGetterDef(Pos pos, mosstring var) {
        if (var == "_")
            return;
        addVal(pos, OPCode.GetterDef, man.addStr(var));
    }

    mosstring getStr(size_t i) {
        assert(i < man.strs.length, format!"str %s out of range (%s)"(i, man.strs.length));
        return man.strs[i];
    }
    private int tempCounter = -1;
    auto addAssignTemp(Pos pos) {
        auto v = man.addStr(mosformat!"_t%d"(++tempCounter));
        addVal(pos, OPCode.Assign, v);
        return v;
    }
    Obj getConst(size_t i) {
        return man.consts[i];
    }

    void addNil(Pos pos) {
        addVal(pos, OPCode.LoadConst, 0);
    }
    void addNull(Pos pos) {
        add(pos, OPCode.AddNull);
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
    mosstring toStr(Pos p, Env e) {
        mosstring r = "";
        if (args.length) {
            r ~= "\nargs:";
            if (isVariadic) r~= "...";
            foreach (a; args) {
                r ~= mosformat!"\n%s: %s"(a, man.getStr(a));
            }
        }
        if (captures.length) {
            r ~= "\ncaptures: ";
            foreach (a; captures) {
                r ~= mosformat!"\ncap:%s"(a);
            }
        }

        mosstring getLabel(ulong pos) {
            mosstring res = "";
            foreach (i, l; man.jumpTable) {
                if (l == pos) { res ~= mosformat!"%4s\n"(mosformat!"L%s:"(i)); }
            }
            return (res.length == 0)? "    ": res[0..$-1];
        }
        foreach (i, o; ops) {
            r ~= mosformat!"\n%s"(o.toStr(p, e, man, getLabel(i)));
        }
        return r;
    }
}
