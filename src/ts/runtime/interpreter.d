module ts.runtime.interpreter;

import ts.ast.token;
import ts.ir.block;
import ts.ir.block_manager;
import ts.ir.compiler;
import ts.runtime.env;
import ts.objects.obj;
import ts.objects.property;
import ts.misc;
import stdd.array;
import stdd.format;
import stdd.variant;
import stdd.range;


import ts.objects.type_meta;
import ts.objects.module_;
import com.log;

public Obj eval(BlockManager man) {
    return eval(man.mainBlock, Pos(-1), new Env(man.mainBlock.st), null, null);
}
public Obj evalDbg(BlockManager man, out Env e) {
    e = new Env(man.mainBlock.st);
    tslog(man.toStr(Pos(-1), e));
    tslog("\nOutput:");
    return eval(man.mainBlock, Pos(-1), e, null, null);
}

Obj checkGetter(Obj x, Pos pos, Env env) {
    return x.visitO!(
        (Property p) => p.callGet(pos, env),
        () => x);
}

public Obj eval(Block bl, Pos initPos, Env env, Obj[] argv, Obj*[uint] captures = null,
                string file =__FILE__, size_t line = __LINE__) {
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

        //writefln("%d %s l=%s", pc, op, len);
        //dfmt off
        final switch (op.code) {
        case OPCode.Nop: break;
        case OPCode.Pop:
            if (len == 0) break;
            //assert (len > 0, "stack underflow");
            stack.popBack();
            break;
        case OPCode.DupTop:
            assert(len>0);
            stack ~= stack.back();
            break;
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
            //tslog!"msg='%s' type = %s l=%s"(str, o.type, args.length);
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
            stack ~= bl.getConst(op.val).checkGetter(pos, env);//check prop probably not needed
        } break;
        case OPCode.LoadVal: {
            stack ~= env.get(pos, op.val);//.checkGetter(pos, env);
        } break;
        case OPCode.LoadLib: {
            stack ~= bl.lib.get(op.val).checkGetter(pos, env);
        } break;
        case OPCode.MakeClosure: {
            auto b = man.blocks[op.val];
            Obj*[uint] caps;
            foreach (c; b.captures) {
                caps[c] = env.getPtr(c);
            }
            stack ~= obj!Closure(b, caps);
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
        case OPCode.SetterDef: {
            assert(len >= 1);
            auto a = pop();
            stack ~= env.setterDef(pos, op.val, a);
        } break;
        case OPCode.PropDef: {
            assert(len >= 1);
            auto set = pop();
            auto get = pop();
            stack ~= env.propDef(pos, op.val, get, set);
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
        case OPCode.MakeModule: {
            auto tmk = bl.man.modules[op.val];
            void impl(bool isType, T)() {
                Obj o = new Obj(T(tmk.name));
                T* t = o.peek!T;
                Obj funcOrClosure(Block b) {
                    if (b.captures.length == 0) return obj!Function(b);
                    Obj*[uint] caps;
                    foreach (c; b.captures) {
                        caps[c] = env.getPtr(c);
                    }
                    return obj!Closure(b, caps);
                }
                foreach (name, b; tmk.methods) {
                    static if (isType) {
                        if (name == "ctor") {
                            t.ctor = funcOrClosure(b);
                        } else {
                            t.members[name] = funcOrClosure(b);
                        }
                    }
                    else {
                        t.members[name] = funcOrClosure(b);
                    }
                }
                static if (isType) {
                    import ts.objects.user_defined;
                    t.members["base"] = obj!Property(
                        obj!BIFunction((Pos p, Env e, Obj[] a) => a[0].peek!UserDefined.base),
                        obj!BIFunction((Pos p, Env e, Obj[] a) => a[0].peek!UserDefined.base = a[1]));
                }
                foreach (name, b; tmk.getters) {
                    assignFuncType!(FuncType.Getter)(t.members, name, obj!Function(b));
                }
                foreach (name, b; tmk.setters) {
                    assignFuncType!(FuncType.Setter)(t.members, name, obj!Function(b));
                }
                // this must be done now because members might be self-referential
                tslog("set MODULE");
                env.set(pos, tmk.name, o);
                Obj*[uint] caps;
                foreach (c; tmk.captures) {
                    caps[c] = env.getPtr(c);
                }

                foreach (name, b; tmk.members) {
                    t.members[name] = b.eval(pos, env, [], caps);
                }
                stack ~= o;
            }
            if (tmk.isType)
                impl!(true, TypeMeta);
            else
                impl!(false, Module);
        }

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
