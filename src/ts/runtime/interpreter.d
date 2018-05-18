module ts.runtime.interpreter;

import ts.ast.token;
import ts.ir.block;
import ts.ir.block_manager;
import ts.ir.compiler;
import ts.type_table;
import ts.builtin;
import ts.runtime.env;
import ts.objects.obj;
import ts.misc;
import stdd.array;
import stdd.format;
import stdd.variant;
import stdd.range;


import com.log;

public Obj eval(BlockManager man) {
    //auto len = man.finish();
    return eval(man.mainBlock, Pos(-1), new Env(man.mainBlock.st), null, null);
}
public Obj eval(Block bl, Pos pos, Env env, Obj[] argv, Obj*[OffsetVal] captures = null) {
    //writefln("eval @%d", bl.st.offset);
    if (env !is null)
        env = new Env(env, bl.st, captures);
    auto length = argv is null ? 0 : argv.length;
    Obj[] stack;
    //dfmt off
    Obj pop() { auto t = stack.back(); stack.popBack(); return t; }
    Obj[] popN(size_t n) {
        auto res = stack[$ - n.. $];
        stack.popBackExactly(n);
        return res;
    }
    void jmp(ref size_t pc, size_t pos) {pc = bl.man.jumpTable[pos]-1;}
    if (bl.args.length != length)
        throw new RuntimeException(pos, format!"Expected %s args, got %s"(bl.args.length, length));
    foreach (i, a; bl.args) {
        env.set(a, argv[i]);
    }


    //writefln("ja %s", stack.length);
    for (size_t pc = 0; pc < bl.ops.length; ++pc) {
        auto op = bl.ops[pc];

        auto len = stack.length;
        //writefln("pc=%d l=%s, %-20s ", pc, stack.length, op.code);
        auto msg = "";

        //writefln("%d %s l=%s", pc, op, len);
        //dfmt off
        final switch (op.code) {
        case OPCode.nop: break;
        case OPCode.pop:
            if (len == 0) break;
            //assert (len > 0, "stack underflow");
            stack.popBack();
            break;
        case OPCode.dupTop:
            assert(len>0);
            stack ~= stack.back();
            break;
        case OPCode.call: {
            assert(len >= op.argc + 1);
            auto args = popN(op.argc);

            auto f = pop();
            stack ~= f.call(op.pos, env, args);
        } break;
        case OPCode.methodCall: {
            assert(len >= op.argc + 1);
            auto args = popN(op.argc+1);
            auto str = bl.getStr(op.val);
            auto o = args.front();
            msg = format!"%s"(str);
            //writefln("msg='%s' type = %s l=%s", str, o.type, args.length);
            stack ~= typeTable.getMember(pos, o.type(), str).call(pos, env, args);
        } break;
        case OPCode.binary: {
            assert(len >= 2);
            auto b = pop();
            auto a = pop();
            auto str = bl.getStr(op.val);
            stack ~= a.binary(pos, env, str, b);
        } break;
        case OPCode.cmp: {
            assert(len >= 2);
            auto b = pop();
            auto a = pop();
            auto val = a.cmp(pos, env, b);
            switch (cast(TT) op.val) {
                case TT.ge: stack ~= objBool(val >= 0); break;
                case TT.le: stack ~= objBool(val <= 0); break;
                case TT.gt: stack ~= objBool(val > 0); break;
                case TT.lt: stack ~= objBool(val < 0); break;
            default: assert(0, "invalid op");
            }
        } break;
        case OPCode.memberSet: {
            assert(len >= 2);
            auto b = pop();
            auto a = pop();
            auto val = bl.getStr(op.val);
            stack ~= typeTable.getMember2(pos, a.type(), tsformat!"%sSet"(val), "opFwdSet",
                                 (Obj f) => f.call(pos, env, a, b),
                                 (Obj f) => f.call(pos, env, a, objString(val), b));
        } break;
        case OPCode.memberGet: {
            assert(len >= 1);
            auto a = pop();
            auto val = bl.getStr(op.val);
            stack ~= typeTable.getMember2(pos, a.type(), tsformat!"%s"(val), "opFwd",
                                 (Obj f) => f.call(pos, env, a),
                                 (Obj f) => f.call(pos, env, a, objString(val)));
        } break;
        case OPCode.subscriptGet: {
            assert(len >= 2);
            auto b = pop();
            auto a = pop();
            stack ~= typeTable.getMember(pos, a.type(), "opIndex")
                .call(pos, env, a, b);
        } break;
        case OPCode.subscriptSet: {
            assert(len >= 3);
            auto c = pop();
            auto b = pop();
            auto a = pop();
            stack ~= typeTable.getMember(pos, a.type(), "opIndexSet")
                .call(pos, env, a, b, c);
        } break;
        case OPCode.return_: {
            assert(len >= 1);
            return pop();
        }
        case OPCode.loadConst: {
            stack ~= bl.getConst(op.val);
        } break;
        case OPCode.loadVal: {
            stack ~= env.get(op);
        } break;
        case OPCode.loadLib: {
            stack ~= bl.lib.get(op.val);
        } break;
        case OPCode.makeClosure: {
            auto cm = bl.man.closures[op.val];
            Obj*[OffsetVal] caps;
            foreach (c; cm.captures) {
                caps[c] = env.getPtr(c);
            }
            stack ~= objClosure(bl.man.blocks[cm.blockIndex], caps);
        } break;
        case OPCode.makeList: {
            assert(len >= op.val);
            auto args = popN(op.val);
            stack ~= objList(args);
        } break;
        case OPCode.makeDict: {
            assert(len >= op.val);
            auto args = popN(op.val);
            stack ~= objDict(args);
        } break;
        case OPCode.assign: {
            assert(len >= 1);
            auto a = pop();
            stack ~= env.set(op, a);
        } break;
        case OPCode.jmp:{
            msg = format!"%d"(op.val);
            jmp(pc, op.val);
        } break;
        case OPCode.jmpIfTrueOrPop: {
            assert(len >= 1);
            auto a = stack.back();
            if (a.toBool())
                jmp(pc, op.val);
            else
                stack.popBack();
        } break;
        case OPCode.jmpIfTruePop: {
            assert(len >= 1);
            auto a = pop();
            if (a.toBool())
                jmp(pc, op.val);
        } break;
        case OPCode.jmpIfFalseOrPop: {
            assert(len >= 1);
            auto a = stack.back();
            if (!a.toBool())
                jmp(pc, op.val);
            else
                stack.popBack();
        } break;
        case OPCode.jmpIfFalsePop: {
            assert(len >= 1);
            auto a = pop();
            if (!a.toBool())
                jmp(pc, op.val);
        } break;

        }
        //if (msg.length > 0)
        //    writefln("(%s)", msg);
    }
    if (stack.length > 1)
        tslog!"<terminated with stacklen %s>"(stack.length);
    if (stack.length > 0)
        return stack.back();
    return nil;
}
