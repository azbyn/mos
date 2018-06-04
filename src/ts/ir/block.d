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
    OffsetVal[] args;
    @property Lib lib() {
        return man.lib;
    }
    @property OffsetVal[] captures() {
        return st.captures;
    }

    this(BlockManager man) {
        this.man = man;
        //man.blocks ~= this;
        _st = new SymbolTable(man);
    }

    this(BlockManager man, tsstring[] argNames, OffsetVal[] captures) {
        this.man = man;
        //man.blocks ~= this;
        _st = new SymbolTable(man, captures, argNames, /*out*/ args);
    }

    OffsetVal[] getCaptures(Pos pos, tsstring[] caps) {
        OffsetVal[] res = uninitializedArray!(OffsetVal[])(caps.length);
        OffsetVal val;
        foreach (i, c; caps) {
            if (st.getName(c, val)) {
                res[i] = val;
            }
            else
                throw new IRException(pos, format!"Can't capture '%s'"(c));
        }
        return res;
    }

    uint str(tsstring name) {
        foreach (i, m; man.strs) {
            if (m == name)
                return cast(uint) i;
        }
        man.strs ~= name;
        return cast(uint)(man.strs.length - 1);
    }

    private void add(Pos pos, OPCode code, ushort argc, uint val) {
        ops ~= OP(pos, code, 0, argc, val);
    }

    private void add(Pos pos, OPCode code, ushort argc, OffsetVal val) {
        ops ~= OP(pos, code, val.offset, argc, val.val);
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
    void addType(Pos pos, TypeMaker tm) {
        man.types ~= tm;
        addVal(pos, OPCode.MakeType, man.types.length - 1);
    }

    void add(Pos pos, OPCode op) {
        add(pos, op, 0, 0);
    }

    void addVal(Pos pos, OPCode op, uint val) {
        add(pos, op, 0, val);
    }

    void addVal(Pos pos, OPCode op, ulong val) {
        addVal(pos, op, cast(uint) val);
    }

    void addVal(Pos pos, OPCode op, OffsetVal val) {
        add(pos, op, 0, val);
    }

    void addArgc(Pos pos, OPCode op, ushort argc) {
        add(pos, op, argc, 0);
    }

    void addArgc(Pos pos, OPCode op, ulong argc) {
        addArgc(pos, op, cast(ushort) argc);
    }

    void addStr(Pos pos, OPCode op, tsstring mem) {
        add(pos, op, 0, str(mem));
    }

    void addStr(Pos pos, OPCode op, ulong argc, tsstring mem) {
        add(pos, op, cast(ushort) argc, str(mem));
    }

    void addVariable(Pos pos, tsstring var) {
        if (var == "_")
            throw new IRException(pos, "Invalid name '_'");
        OffsetVal res;
        size_t lres;
        if (st.getName(var, res)) {
            addVal(pos, OPCode.LoadVal, res);
        }
        else if (lib.get(var, lres)) {
            addVal(pos, OPCode.LoadLib, lres);
        }
        else
            throw new IRException(pos, format!"'%s' not defined"(var));
    }
    OffsetVal addOV(Pos pos, tsstring var) {
        if (var == "_")
            throw new IRException(pos, "Invalid name '_'");
        return st.get(pos, var);
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
        addVal(pos, OPCode.Assign, st.get(pos,var));
    }
    void addSetterDef(Pos pos, tsstring var) {
        if (var == "_")
            return;
        addVal(pos, OPCode.SetterDef, st.get(pos, var));
    }
    void addGetterDef(Pos pos, tsstring var) {
        if (var == "_")
            return;
        addVal(pos, OPCode.GetterDef, st.get(pos, var));
    }

    tsstring getStr(size_t i) {
        assert(i < man.strs.length, format!"str %s out of range (%s)"(i, man.strs.length));
        return man.strs[i];
    }
    private int tempCounter = -1;
    auto addAssignTemp(Pos pos) {
        auto v = st.get(pos, tsformat!"_t%d"(++tempCounter));
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
        r ~= tsformat!"\noffset = %d"(st.offset);
        if (args !is null) {
            r ~= "\nargs: ";
            foreach (a; args) {
                r ~= tsformat!"\no:%s, %s: %s"(a.offset, a.val, st.getStr(a));
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
            case OPCode.MakeType:
                r ~= tsformat!"(%s)"(man.types[o.val].toString(p, e));
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
            case OPCode.MethodCall:
            case OPCode.MemberGet:
            case OPCode.MemberSet:
                r ~= tsformat!"(%s)"(man.strs[o.val]);
                break;
                //case OPCode.SubscriptGet:
                //case OPCode.SubscriptSet:
            case OPCode.LoadVal:
            case OPCode.Assign:
            case OPCode.SetterDef:
                r ~= tsformat!"(%s)"(st.getStr(o));
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
