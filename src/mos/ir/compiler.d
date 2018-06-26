module mos.ir.compiler;

import stdd.array;
import stdd.variant;
import stdd.algorithm;
import stdd.format;
import mos.objects.obj;
import mos.ast.ast_node;
import mos.ast.token;
import mos.ir.block_manager;
import mos.ir.block;
import mos.ir.lib;
import mos.misc;
import com.log;


enum OPCode {
    Nop,
    Pop,
    //DupTop, // is evil, or at least I couldn't make it work properly
    Call,
    AddNull,
    MemberSet,
    MemberGet,
    SubscriptGet,
    SubscriptSet,
    Return,
    LoadConst,
    LoadVal,
    LoadLib,
    Assign,
    SetterDef,
    GetterDef,
    MakeList,
    MakeTuple,
    MakeDict,
    MakeStaticClosure,
    MakeMethodClosure,
    Property,
    AddModule,
    AddModuleMember,
    AddStruct,
    AddStatic,
    AddInstance,
    Jmp,
    Cmp,
    Cat,
    This,
    Binary,
    JmpIfTrueOrPop, // if (prev) { jmp } else { pop }
    JmpIfFalseOrPop, // if (!prev) { jmp } else { pop }
    JmpIfTruePop, // if (prev) { jmp }  pop
    JmpIfFalsePop, // if (!prev) { jmp } pop
}

struct OP {
    Pos pos;
    OPCode code;
    //ushort argc;
    uint val;
    string toString() { assert(0, "please use toStr"); }
    mosstring toStr(Pos p, Env e, BlockManager man, mosstring label = "") {
        mosstring res = mosformat!"%s %-20s v:%d"(label, code, val);
        switch (code) {
        case OPCode.MakeStaticClosure:
        case OPCode.MakeMethodClosure:
            return res ~ mosformat!"(%s)"(man.blocks[val].toStr(p, e));
        case OPCode.LoadConst:
            return res ~ mosformat!"(%s)"(man.consts[val].toStr(p, e));
        case OPCode.Cmp:
            return res ~ mosformat!"(%s)"(symbolicStr(cast(TT) val));
        case OPCode.Binary:
        case OPCode.MemberGet:
        case OPCode.MemberSet:
        case OPCode.AddModuleMember:
        case OPCode.AddInstance:
        case OPCode.AddStatic:
        case OPCode.AddStruct:
        case OPCode.AddModule:
        case OPCode.LoadVal:
        case OPCode.Assign:
        case OPCode.GetterDef:
        case OPCode.SetterDef:
            return res ~ mosformat!"(%s)"(man.getStr(val));
        case OPCode.LoadLib:
            return res ~ mosformat!"(%s)"(man.lib.getName(val));
        case OPCode.Jmp:
        case OPCode.JmpIfFalseOrPop:
        case OPCode.JmpIfTrueOrPop:
        case OPCode.JmpIfFalsePop:
        case OPCode.JmpIfTruePop:
            return res ~ mosformat!"(L%s)"(val);
        default:
            return res;
        }
    }
}

Block generateIR(bool isStatic)(AstNode n, Block parent, mosstring[] captures, mosstring[] args, bool isVariadic) {
    return generateIR!isStatic(n, parent, parent.man.getBulk(captures), parent.man.addBulk(args), isVariadic);
}
Block generateIR(bool isStatic)(AstNode n, Block parent, uint[] captures, uint[] args, bool isVariadic) {
    assert(parent);
    assert(parent.man);
    //assert(parent.man);
    Block bl = new Block(parent.man, args, captures, isVariadic);
    if (auto body_ = n.val.peek!(AstNode.Body)){
        foreach (node; body_.val) {
            nodeIR!isStatic(node, bl);
            bl.add(n.pos, OPCode.Pop);
        }
        if (bl.ops.length > 1)
            bl.ops.popBack();
    }
    else nodeIR!isStatic(n, bl);
    return bl;
}

BlockManager generateIR(AstNode[] nodes, Lib lib) {
    Block bl;
    BlockManager man = new BlockManager(lib, bl);
    foreach (n; nodes) {
        nodeIR!true(n, bl);
        bl.add(n.pos, OPCode.Pop);
    }
    return man;
}
public void nodeIR(bool isStatic)(AstNode n, Block bl, uint[] captures = null, long loopBeg = -1, long loopEnd = -1) {
    assert(bl);
    assert(n);
    void ir(bool isStatic = true)(AstNode node, long beg = loopBeg, long end = loopEnd) {
        nodeIR!isStatic(node, bl, null, beg, end);
    }
    void irStatic(AstNode node, uint[] captures) {
        nodeIR!true(node, bl, captures, loopBeg, loopEnd);
    }
    void irInstance(AstNode node, uint[] captures) {
        nodeIR!false(node, bl, captures, loopBeg, loopEnd);
    }
    auto pos = n.pos;
    //dfmt off
    n.val.visit!(
        (AstNode.Comma v) {
            ir(v.a);
            bl.add(pos, OPCode.Pop);
            ir(v.b);
        },
        (AstNode.ReverseComma v) {
            ir(v.a);
            ir(v.b);
            bl.add(pos, OPCode.Pop);
        },
        (AstNode.String v) {
            bl.addConst(pos, obj!String(v.val));
        },
        (AstNode.Float v) {
            bl.addConst(pos, obj!Float(v));
        },
        (AstNode.Int v) {
            bl.addConst(pos, obj!Int(v));
        },
        (AstNode.Bool v) {
            bl.addConst(pos, obj!Bool(v));
        },
        (AstNode.Nil v) {
            bl.addNil(pos);
        },
        (AstNode.This v) {
            bl.add(pos, OPCode.This);
        },
        (AstNode.Variable v) {
            bl.addVariable(pos, v.name);
        },
        (AstNode.FuncCall v) {
            ir(v.func);
            foreach (n; v.args) {
                ir(n);
            }
            bl.addVal(pos, OPCode.Call, v.args.length);
        },
        (AstNode.Binary v) {
            ir(v.a);
            ir(v.b);
            bl.addStr(pos, OPCode.Binary, v.name);
        },
        (AstNode.Lambda v) {
            auto block = generateIR!isStatic(v.body_, bl, bl.man.getBulk(v.captures) ~ captures,
                                             bl.man.addBulk(v.params), v.isVariadic);
            bl.addClosureOrFunc!isStatic(pos, block);
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
                    bl.addStr(pos, OPCode.MemberSet, r.member);
                },
                (AstNode.Subscript r) {
                    ir(r.val);
                    ir(r.index);
                    ir(v.lvalue);
                    bl.add(pos, OPCode.SubscriptSet);
                },
                () { throw new IRException(pos, "Invalid assignment"); }
            )();
        },
        (AstNode.SetterDef v) {
            ir(v.val);
            bl.addSetterDef(pos, v.name);
        },
        (AstNode.GetterDef v) {
            ir(v.val);
            bl.addGetterDef(pos, v.name);
        },
        (AstNode.Property v) {
            if (v.get !is null) ir(v.get);
            else bl.addNull(pos);

            if (v.set !is null) ir(v.set);
            else bl.addNull(pos);
            bl.add(pos, OPCode.Property);
        },
        (AstNode.Subscript v) {
            ir(v.val);
            ir(v.index);
            bl.add(pos, OPCode.SubscriptGet);
        },
        (AstNode.Member v) {
            ir(v.val);
            bl.addStr(pos, OPCode.MemberGet, v.member);
        },
        (AstNode.And v) {
            ir(v.a);
            auto j = bl.addJmp(pos, OPCode.JmpIfFalseOrPop);
            ir(v.b);
            bl.setJmpHere(j);
        },
        (AstNode.Or v) {
            ir(v.a);
            auto j = bl.addJmp(pos, OPCode.JmpIfTrueOrPop);
            ir(v.b);
            bl.setJmpHere(j);
        },
        (AstNode.If v) {
            ir(v.cond);
            auto j1 = bl.addJmp(pos, OPCode.JmpIfFalseOrPop);
            ir(v.body_);
            auto j2 = bl.addJmp(pos, OPCode.Jmp);
            bl.setJmpHere(j1);
            if (v.else_ !is null)
                ir(v.else_);
            bl.setJmpHere(j2);
        },
        (AstNode.While v) {
            auto beg = bl.here();
            auto end = bl.reserveJmp();
            ir(v.cond);
            bl.addVal(pos, OPCode.JmpIfFalseOrPop, end);
            ir(v.body_, beg, end);
            bl.addVal(pos, OPCode.Jmp, beg);
            bl.setJmpHere(end);
        },
        (AstNode.For v) {
            /*
              iter = collection.Iter;
            beg:
              v.index = iter.Index;
              v.val = iter.Val;
              body();
            next:
              if (iter.next()) goto beg;
            end:
             */
            ir(v.collection);
            bl.addStr(pos, OPCode.MemberGet, "Iter");
            auto iter = bl.addAssignTemp(pos);
            bl.add(pos, OPCode.Pop);
            auto beg = bl.here();
            auto next = bl.reserveJmp();
            auto end = bl.reserveJmp();

            bl.addVal(pos, OPCode.LoadVal, iter);
            bl.addStr(pos, OPCode.MemberGet, "Index");
            bl.addAssign(pos, v.index);
            bl.add(pos, OPCode.Pop);

            bl.addVal(pos, OPCode.LoadVal, iter);
            bl.addStr(pos, OPCode.MemberGet, "Val");
            bl.addAssign(pos, v.val);
            bl.add(pos, OPCode.Pop);
            ir(v.body_, beg, end);

            bl.setJmpHere(next);
            bl.addVal(pos, OPCode.LoadVal, iter);
            bl.addStr(pos, OPCode.MemberGet, "next");
            bl.addVal(pos, OPCode.Call, 0);
            bl.addVal(pos, OPCode.JmpIfTruePop, beg);
            bl.setJmpHere(end);
        },
        (AstNode.Body v) {
            //bodies don't create a new scope
            foreach(n; v.val) {
                ir(n);
                bl.add(pos, OPCode.Pop);
            }
        },
        (AstNode.List v) {
            foreach(n; v.val) {
                ir(n);
            }
            bl.addVal(pos, OPCode.MakeList, v.val.length);
        },
        (AstNode.Tuple v) {
            foreach(n; v.val) {
                ir(n);
            }
            bl.addVal(pos, OPCode.MakeTuple, v.val.length);
        },
        (AstNode.Dict v) {
            foreach(n; v.val) {
                ir(n);
            }
            bl.addVal(pos, OPCode.MakeDict, v.val.length);
        },

        (AstNode.Cmp v) {
            ir(v.a);
            ir(v.b);
            bl.addVal(pos, OPCode.Cmp, cast(int)v.op);
        },
        (AstNode.Cat v) {
            ir(v.a);
            ir(v.b);
            bl.add(pos, OPCode.Cat);
        },

        (AstNode.Return v) {
            ir(v.val);
            bl.add(pos, OPCode.Return);
        },
        (AstNode.CtrlFlow v) {
            //import ts.ast.parser;
            if (loopBeg == -1)
                throw new IRException(pos, format!"Found %s outside loop"(v.type.symbolicStr));
            assert (loopEnd != -1);
            auto j = v.type == TT.Break ? loopEnd : loopBeg;
            moslog!"jmp from %d-%d: %d"(loopBeg, loopEnd, j);
            bl.addVal(pos, OPCode.Jmp, j);
        },
        (AstNode.Module v) {
            bl.addStr(pos, OPCode.AddModule, v.name);
            //bl.addConst(pos, obj!Module(v.name));
            bl.addAssign(pos, v.name);
            uint[] cap = [bl.man.addStr(v.name)];
            foreach (name, mem; v.members) {
                bl.addVariable(pos, v.name);
                irStatic(mem, cap);
                bl.addStr(pos, OPCode.AddModuleMember, name);
            }
        },
        (AstNode.Struct v) {
            bl.addStr(pos, OPCode.AddStruct, v.name);
            /*bl.addConst(pos, obj!TypeMeta(v.name));
              bl.addAssign(pos, v.name);*/

            uint[] cap = [bl.man.addStr(v.name)];
            foreach (name, mem; v.statics) {
                bl.addVariable(pos, v.name);
                irStatic(mem, cap);
                bl.addStr(pos, OPCode.AddStatic, name);
            }
            foreach (name, mem; v.instance) {
                bl.addVariable(pos, v.name);
                irInstance(mem, cap);
                bl.addStr(pos, OPCode.AddInstance, name);
            }
            if (v.ctor !is null) {
                bl.addVariable(pos, v.name);
                irInstance(v.ctor, cap);
                bl.addStr(pos, OPCode.AddInstance, "0ctor");
            }
            //bl.add(pos, OPCode.Pop);

        },
    );
    //dfmt on
}
