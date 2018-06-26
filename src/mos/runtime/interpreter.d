module mos.runtime.interpreter;

import mos.ast.token;
import mos.ir.block;
import mos.ir.block_manager;
import mos.ir.compiler;
import mos.runtime.env;
import mos.objects.obj;
import mos.objects.property;
import mos.misc;
import stdd.array;
import stdd.format;
import stdd.variant;
import stdd.range;


import mos.objects.type_meta;
import mos.objects.module_;
import com.log;

public Obj eval(BlockManager man) {
    return eval(man.mainBlock, null, Pos(-1), new Env(man), null, null);
}
public Obj evalDbg(BlockManager man, out Env e) {
    e = new Env(man);
    moslog(man.toStr(Pos(-1), e));
    moslog("\nOutput:");
    return eval(man.mainBlock, null, Pos(-1), e, null, null);
}

Obj checkGetter(Obj x, Pos pos, Env env) {
    return x.visitO!(
        (Property p) => p.callGet(pos, env),
        () => x);
}
/*
public Obj evalStatic(Block bl, Pos initPos, Env env, Obj[] argv, Obj*[uint] captures = null,
                string file =__FILE__, size_t line = __LINE__)  {
    return eval(bl, null, initPos, env, argv, captures, file, line);
    }*/
public Obj eval(Block bl, Obj this_, Pos initPos, Env env, Obj[] argv, Obj*[uint] captures = null,
                string file =__FILE__, size_t line = __LINE__) {
    if (env !is null)
        env = new Env(env, bl.man, captures);
    auto length = argv is null ? 0 : argv.length;
    Obj[] stack;
    void stackPuke(mosstring why) {
        moslog!"\nstackPuke: %s (len=%s)"(why, stack.length);
        foreach (i, v; stack) {
            moslog!"stack@%s= %s"(i, v.typestr);//toStr(initPos, env));
        }
    }
    //dfmt off
    Obj pop() { auto t = stack.back(); stack.popBack(); return t; }
    Obj[] popN(size_t n) {
        auto res = stack[$ - n.. $];
        stack.popBackExactly(n);
        return res;
    }
    void jmp(ref size_t pc, size_t pos) {pc = bl.man.jumpTable[pos]-1;}
    if (bl.isVariadic) {
        auto vlen = bl.args.length -1;
        if (length < vlen)
            throw new RuntimeException(initPos, format!"Expected at least %s args, got %s"(bl.args.length, length), file, line);
        argv = argv[0..vlen] ~ obj!Tuple(argv[vlen..$]);
        //argv =vargs;
    }
    else if (bl.args.length != length) {
        throw new RuntimeException(initPos, format!"Expected %s args, got %s"(bl.args.length, length), file, line);
    }
    foreach (i, a; bl.args) {
        env.set(initPos, a, argv[i]);
    }
    auto man = bl.man;

    //writefln("ja %s", stack.length);
    for (size_t pc = 0; pc < bl.ops.length; ++pc) {
        auto op = bl.ops[pc];

        auto len = stack.length;
        //writefln("pc=%d l=%s, %-20s ", pc, stack.length, op.code);
        auto msg = "";
        auto pos = op.pos;

        moslog!"%-2d %s"(pc, op.toStr(pos, env, man));
        //dfmt off
        final switch (op.code) {
        case OPCode.Nop: break;
        case OPCode.AddNull:
            stack ~= null;
            break;
        case OPCode.This:
            assert(this_ !is null);
            stack ~= this_;
            break;
        case OPCode.Pop:
            if (len == 0) {
                moslog("!dryPop");
                break;
            }
            //assert (len > 0, "stack underflow");
            stack.popBack();
            break;
            /*
        case OPCode.DupTop:
            stack ~= stack.back();
            break;*/
        case OPCode.Call: {
            assert(len >= op.val + 1);
            auto args = popN(op.val);
            auto f = pop();
            stack ~= f.call(op.pos, env, args);
        } break;
/*
        case OPCode.MethodCall: {
            assert(len >= op.argc + 1);
            auto args = popN(op.argc+1);
            auto str = bl.getStr(op.val);
            auto o = args.front();
            if (o.peek!TypeMeta|| o.peek!Module) {
                //we don't pass this
                args = args[1..$];
            }
            //moslog!"msg='%s' type = %s l=%s"(str, o.type, args.length);
            stack ~= env.getMember(pos, o/*.type()* /, str).call(pos, env, args);
        } break;*/
        case OPCode.Binary: {
            assert(len >= 2);
            auto b = pop();
            auto a = pop();
            auto str = bl.getStr(op.val);
            stack ~= a.binary(pos, env, str, b);
        } break;
        case OPCode.Cmp: {
            assert(len >= 2);
            auto b = pop();
            auto a = pop();
            auto val = a.cmp(pos, env, b);
            switch (cast(TT) op.val) {
                case TT.Ge: stack ~= obj!Bool(val >= 0); break;
                case TT.Le: stack ~= obj!Bool(val <= 0); break;
                case TT.Gt: stack ~= obj!Bool(val > 0); break;
                case TT.Lt: stack ~= obj!Bool(val < 0); break;
            default: assert(0, "invalid op");
            }
        } break;
        case OPCode.Cat: {
            assert(len >= 2);
            auto b = pop();
            auto a = pop();
            stack ~= obj!String(a.toStr(pos, env) ~ b.toStr(pos, env));
        } break;
        case OPCode.MemberSet: {
            assert(len >= 2);
            auto b = pop();
            auto a = pop();
            auto val = bl.getStr(op.val);
            stack ~= a.setMember(pos, env, val, b);
        } break;
        case OPCode.MemberGet: {
            assert(len >= 1);
            auto a = pop();
            auto val = bl.getStr(op.val);
            stack ~= a.member(pos, env, val);
        } break;
        case OPCode.SubscriptGet: {
            assert(len >= 2);
            auto b = pop();
            auto a = pop();
            stack ~= a.memberCall(pos, env, "opIndex", b);
        } break;
        case OPCode.SubscriptSet: {
            assert(len >= 3);
            auto c = pop();
            auto b = pop();
            auto a = pop();
            stack ~= a.memberCall(pos, env, "opIndexSet", b, c);
        } break;
        case OPCode.Return: {
            assert(len >= 1);
            return pop();
        }
        case OPCode.LoadConst: {
            stack ~= bl.getConst(op.val).checkGetter(pos, env);
        } break;
        case OPCode.LoadVal: {
            stack ~= env.get(pos, op.val);
        } break;
        case OPCode.LoadLib: {
            stack ~= bl.lib.get(op.val).checkGetter(pos, env);
        } break;
        case OPCode.MakeStaticClosure: {
            auto b = man.blocks[op.val];
            Obj*[uint] caps;
            foreach (c; b.captures) {
                caps[c] = env.getPtr(c);
            }
            stack ~= obj!StaticClosure(b, caps);
        } break;
        case OPCode.MakeMethodClosure: {
            auto b = man.blocks[op.val];
            Obj*[uint] caps;
            foreach (c; b.captures) {
                caps[c] = env.getPtr(c);
            }
            stack ~= obj!MethodClosureMaker(b, caps);
        } break;
        case OPCode.Property: {
            assert(len >= 2);
            auto set = pop();
            auto get = pop();
            assert(set is null || !set.isNil);
            assert(get is null || !get.isNil);
            /*if (set.isNil()) set = null;
              if (get.isNil()) get = null;*/
            stack ~= obj!Property(get, set);
        } break;
        case OPCode.MakeList: {
            assert(len >= op.val);
            auto args = popN(op.val);
            stack ~= obj!List(args);
        } break;
        case OPCode.MakeTuple: {
            assert(len >= op.val);
            auto args = popN(op.val);
            stack ~= obj!Tuple(args);
        } break;
        case OPCode.MakeDict: {
            assert(len >= op.val);
            auto args = popN(op.val);
            stack ~= obj!Dict(args);
        } break;
        case OPCode.Assign: {
            assert(len >= 1);
            auto a = pop();
            stack ~= env.set(pos, op.val, a);
        } break;
        case OPCode.AddModule: {
            auto name = man.getStr(op.val);
            stack ~= env.set(pos, op.val, obj!Module(name));
        } break;
        case OPCode.AddStruct: {
            auto name = man.getStr(op.val);
            stack ~= env.set(pos, op.val, obj!TypeMeta(name));
        } break;
        case OPCode.SetterDef: {
            assert(len >= 1);
            auto a = pop();
            stack ~= env.setterDef(pos, op.val, a);
        } break;
        case OPCode.GetterDef: {
            assert(len >= 1);
            auto a = pop();
            stack ~= env.getterDef(pos, op.val, a);
        } break;
        case OPCode.Jmp: {
            msg = format!"%d"(op.val);
            jmp(pc, op.val);
        } break;
        case OPCode.JmpIfTrueOrPop: {
            assert(len >= 1);
            auto a = stack.back();
            if (a.toBool(pos, env))
                jmp(pc, op.val);
            else
                stack.popBack();
        } break;
        case OPCode.JmpIfTruePop: {
            assert(len >= 1);
            auto a = pop();
            if (a.toBool(pos, env))
                jmp(pc, op.val);
        } break;
        case OPCode.JmpIfFalseOrPop: {
            assert(len >= 1);
            auto a = stack.back();
            if (!a.toBool(pos, env))
                jmp(pc, op.val);
            else
                stack.popBack();
        } break;
        case OPCode.JmpIfFalsePop: {
            assert(len >= 1);
            auto a = pop();
            if (!a.toBool(pos, env))
                jmp(pc, op.val);
        } break;
        case OPCode.AddModuleMember: {
            assert(len >= 2);
            auto str = man.getStr(op.val);
            auto val = pop();
            auto mod = pop();
            mod.peek!Module.members[str] = val;
        } break;
        case OPCode.AddStatic: {
            assert(len >= 2);
            auto str = man.getStr(op.val);
            auto val = pop();
            auto tm = pop();
            tm.peek!TypeMeta.statics[str] = val;
        } break;
        case OPCode.AddInstance: {
            assert(len >= 2);
            stackPuke("addinstance");
            auto str = man.getStr(op.val);
            auto val = pop();
            auto tm = pop();
            tm.peek!TypeMeta.instance[str] = val;
        } break;
        }
        //if (msg.length > 0)
        //    writefln("(%s)", msg);
    }
    if (stack.length > 1)
        moslog!"<terminated with stacklen %s>"(stack.length);
    if (stack.length > 0)
        return stack.back();
    return nil;
}
