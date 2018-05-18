module ts.ir.compiler;

import stdd.array;
import stdd.variant;
import stdd.algorithm;
import stdd.format;
import ts.objects.obj;
import ts.ast.ast_node;
import ts.ast.token;
import ts.ir.block_manager;
import ts.ir.block;
import ts.ir.symbol_table;
import ts.ir.lib;
import ts.misc;
import com.log;


//TODO make case insensitive?

enum OPCode {
    nop,
    pop,
    dupTop,
    call,
    memberSet,
    memberGet,
    methodCall,
    subscriptGet,
    subscriptSet,
    return_,
    loadConst,
    loadVal,
    loadLib,
    assign,
    makeList,
    makeDict,
    makeClosure,
    jmp,
    cmp,
    binary,
    jmpIfTrueOrPop, // if (prev) { jmp } else { pop }
    jmpIfFalseOrPop, // if (!prev){ jmp } else { pop }
    jmpIfTruePop, // if (prev) { jmp }  pop
    jmpIfFalsePop, // if (!prev) { jmp } pop
}

struct OP {
    Pos pos;
    OPCode code;
    ushort offset;
    ushort argc;
    uint val;
    tsstring toString() {
        if (offset)
            return tsformat!"%-20s o:%d a:%d v:%d"(code, offset, argc, val);
        else
            return tsformat!"%-20s a:%d v:%d"(code, argc, val);
    }
}
struct OffsetVal {
    ushort offset;
    uint val;
    this(ushort offset, uint val) {
        this.offset = offset;
        this.val = val;
    }
    this(ushort offset, ulong val) {
        this(offset, cast(uint) val);
    }
    size_t toHash() const @safe nothrow {
        return cast(size_t) offset << (4 * 6/*8*/) | val;
    }
    bool opEquals(const OP o) const {
        return o.offset == offset && o.val == val;
    }

    bool opEquals(const OffsetVal o) const {
        return o.offset == offset && o.val == val;
    }
    tsstring toString() {
        return tsformat!"%d-%d"(offset, val);
    }
}

Block generateIR(AstNode n, Block parent, OffsetVal[] captures, tsstring[] args) {
    Block bl = new Block(parent, args, captures);
    if (auto body_ = n.val.peek!(AstNode.Body)){
        foreach (node; body_.val) {
            nodeIR(node, bl);
            bl.add(n.pos, OPCode.pop);
        }
        if (bl.ops.length > 1)
            bl.ops.popBack();
    }
    else nodeIR(n, bl);
    return bl;
}

BlockManager generateIR(AstNode[] nodes, Lib lib) {
    Block bl;
    BlockManager man = new BlockManager(lib, bl);
    foreach (n; nodes) {
        nodeIR(n, bl);
        bl.add(n.pos, OPCode.pop);
    }
    return man;
}
private void nodeIR(AstNode n, Block bl, ulong loopBeg = -1, ulong loopEnd = -1) {
    assert(bl);
    void ir(AstNode node, ulong beg = loopBeg, ulong end = loopEnd) {
        return node.nodeIR(bl, beg, end);
    }
    auto pos = n.pos;
    //dfmt off
    n.val.visit!(
        (AstNode.Comma v) {
            ir(v.a);
            bl.add(pos, OPCode.pop);
            ir(v.b);
        },
        (AstNode.ReverseComma v) {
            ir(v.a);
            ir(v.b);
            bl.add(pos, OPCode.pop);
        },
        (AstNode.String v) {
            bl.addConst(pos, objString(v.val));
        },
        (AstNode.Float v) {
            bl.addConst(pos, objFloat(v));
        },
        (AstNode.Int v) {
            bl.addConst(pos, objInt(v));
        },
        (AstNode.Bool v) {
            bl.addConst(pos, objBool(v));
        },
        (AstNode.Nil v) {
            bl.addNil(pos);
        },
        (AstNode.Variable v) {
            bl.addVariable(pos, v.name);
        },
        (AstNode.FuncCall v) {
            ir(v.func);
            foreach (n; v.args) {
                ir(n);
            }
            bl.addArgc(pos, OPCode.call, v.args.length);
        },
        (AstNode.MethodCall v) {
            ir(v.obj);
            if (v.args !is null) {
                foreach (n; v.args) {
                    ir(n);
                }
                bl.addStr(pos, OPCode.methodCall, v.args.length, v.name);
            }
            else {
                bl.addStr(pos, OPCode.methodCall, 0, v.name);
            }
        },
        (AstNode.Binary v) {
            ir(v.a);
            ir(v.b);
            bl.addStr(pos, OPCode.binary, v.name);
        },
        (AstNode.Lambda v) {
            auto block = generateIR(v.body_, bl, bl.getCaptures(pos, v.captures), v.params);
            bl.addClosureOrFunc(pos, block);
        },
        (AstNode.Assign v) {
            v.rvalue.val.tryVisit!(
                (AstNode.Variable r) {
                    ir(v.lvalue);
                    bl.addAssign(pos, r.name);
                },
                (AstNode.Member r) {
                    ir(r.val);
                    ir(v.lvalue);
                    bl.addStr(pos, OPCode.memberSet, r.member);
                },
                (AstNode.Subscript r) {
                    ir(r.val);
                    ir(r.index);
                    ir(v.lvalue);
                    bl.add(pos, OPCode.subscriptSet);
                },
                () { throw new IRException(pos, "Invalid assignment"); }
            )();
        },
        (AstNode.Subscript v) {
            ir(v.val);
            ir(v.index);
            bl.add(pos, OPCode.subscriptGet);
        },
        (AstNode.Member v) {
            ir(v.val);
            bl.addStr(pos, OPCode.memberGet, v.member);
        },
        (AstNode.And v) {
            ir(v.a);
            auto j = bl.addJmp(pos, OPCode.jmpIfFalseOrPop);
            ir(v.b);
            bl.setJmpHere(j);
        },
        (AstNode.Or v) {
            ir(v.a);
            auto j = bl.addJmp(pos, OPCode.jmpIfTrueOrPop);
            ir(v.b);
            bl.setJmpHere(j);
        },
        (AstNode.If v) {
            ir(v.cond);
            auto j1 = bl.addJmp(pos, OPCode.jmpIfFalseOrPop);
            ir(v.body_);
            auto j2 = bl.addJmp(pos, OPCode.jmp);
            bl.setJmpHere(j1);
            if (v.else_ !is null)
                ir(v.else_);
            bl.setJmpHere(j2);
        },
        (AstNode.While v) {
            auto beg = bl.here();
            auto end = bl.reserveJmp();
            ir(v.cond);
            bl.addVal(pos, OPCode.jmpIfFalseOrPop, end);
            ir(v.body_, beg, end);
            bl.addVal(pos, OPCode.jmp, beg);
            bl.setJmpHere(end);
        },
        (AstNode.For v) {
            /*
              iter = collection.Iter();
            beg:
              v.index = iter.Index();
              v.val = iter.Val();
              body();
            next:
              if (iter.next()) goto beg;
            end:
             */
            ir(v.collection);
            bl.addStr(pos, OPCode.methodCall, 0, "Iter");
            auto iter = bl.addAssignTemp(pos);
            bl.add(pos, OPCode.pop);
            auto beg = bl.here();
            auto next = bl.reserveJmp();
            auto end = bl.reserveJmp();

            bl.addVal(pos, OPCode.loadVal, iter);
            bl.addStr(pos, OPCode.methodCall, 0, "Index");
            bl.addAssign(pos, v.index);
            bl.add(pos, OPCode.pop);

            bl.addVal(pos, OPCode.loadVal, iter);
            bl.addStr(pos, OPCode.methodCall, 0, "Val");
            bl.addAssign(pos, v.val);
            bl.add(pos, OPCode.pop);
            ir(v.body_, beg, end);

            bl.setJmpHere(next);
            bl.addVal(pos, OPCode.loadVal, iter);
            bl.addStr(pos, OPCode.methodCall, 0, "next");
            bl.addVal(pos, OPCode.jmpIfTruePop, beg);
            bl.setJmpHere(end);
        },
        (AstNode.Body v) {
            //bodies don't create a new scope
            foreach(n; v.val) {
                ir(n);
                bl.add(pos, OPCode.pop);
            }
        },
        (AstNode.List v) {
            foreach(n; v.val) {
                ir(n);
            }
            bl.addVal(pos, OPCode.makeList, v.val.length);
        },
        (AstNode.Dict v) {
            foreach(n; v.val) {
                ir(n);
            }
            bl.addVal(pos, OPCode.makeDict, v.val.length);
        },

        (AstNode.Cmp v) {
            ir(v.a);
            ir(v.b);
            bl.addVal(pos, OPCode.cmp, cast(int)v.op);
        },
        (AstNode.Return v) {
            ir(v.val);
            bl.add(pos, OPCode.return_);
        },
        (AstNode.CtrlFlow v) {
            //import ts.ast.parser;
            if (loopBeg == -1)
                throw new IRException(pos, format!"Found %s outside loop"(v.type.symbolicStr));
            assert (loopEnd != -1);
            auto j = v.type == TT.break_ ? loopEnd : loopBeg;
            tslog!"jmp from %d-%d: %d"(loopBeg, loopEnd, j);
            bl.addVal(pos, OPCode.jmp, j);
        },
    )();
    //dfmt on
}
