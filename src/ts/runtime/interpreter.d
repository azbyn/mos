module ts.runtime.interpreter;

import ts.ast.token;
import ts.ir.block;
import ts.ir.block_manager;
import ts.ir.compiler;
import ts.type_table;
import ts.builtin;
import ts.runtime.env;
import ts.objects.obj;
import ts.objects.property;
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
private Obj checkGetter(Obj x, Pos pos, Env env) {
    return x.val.tryVisit!(
        (Property p) => p.callGet(pos, env),
        () => x);
}

public Obj eval(Block bl, Pos pos, Env env, Obj[] argv, Obj*[OffsetVal] captures = null,
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
    if (bl.args.length != length)
        throw new RuntimeException(pos, format!"Expected %s args, got %s"(bl.args.length, length), file, line);
    foreach (i, a; bl.args) {
        env.set(pos, env, a, argv[i]);
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
            assert(len >= op.argc + 1);
            auto args = popN(op.argc);

            auto f = pop();
            stack ~= f.call(op.pos, env, args);
        } break;
        case OPCode.MethodCall: {
            import ts.objects.type_meta;
            assert(len >= op.argc + 1);
            auto args = popN(op.argc+1);
            auto str = bl.getStr(op.val);
            auto o = args.front();
            if (o.peek!TypeMeta) {
                //we don't pass this
                args = args[1..$];
            }
            //tslog!"msg='%s' type = %s l=%s"(str, o.type, args.length);
            stack ~= typeTable.getMember(pos, env, o/*.type()*/, str).call(pos, env, args);
        } break;
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
                case TT.Ge: stack ~= objBool(val >= 0); break;
                case TT.Le: stack ~= objBool(val <= 0); break;
                case TT.Gt: stack ~= objBool(val > 0); break;
                case TT.Lt: stack ~= objBool(val < 0); break;
            default: assert(0, "invalid op");
            }
        } break;
        case OPCode.MemberSet: {
            assert(len >= 2);
            auto b = pop();
            auto a = pop();
            auto val = bl.getStr(op.val);
            Obj setterErr(Obj o) {
                throw new RuntimeException(pos, format!"%s doesn't have a setter"(val));
            }
            stack ~= typeTable.getMember2(pos, a.type(), tsformat!"%s"(val), "opFwdSet",
                                 (Obj f) => f.val.tryVisit!(
                                     (Property p) => p.callSetMember(pos, env, a, b),
                                     () => setterErr(f)),
                                 (Obj f) => f.call(pos, env, a, objString(val), b));
        } break;
        case OPCode.MemberGet: {
            assert(len >= 1);
            auto a = pop();
            auto val = bl.getStr(op.val);
            stack ~= typeTable.getMember2(pos, a.type(), tsformat!"%s"(val), "opFwd",
                                (Obj f) =>f.val.tryVisit!(
                                     (Property p) => p.callGetMember(pos, env, a),
                                     () => f),
                                (Obj f) => f.call(pos, env, a, objString(val)));
        } break;
        case OPCode.SubscriptGet: {
            assert(len >= 2);
            auto b = pop();
            auto a = pop();
            stack ~= typeTable.getMember_(pos, a.type(), "opIndex")
                .call(pos, env, a, b);
        } break;
        case OPCode.SubscriptSet: {
            assert(len >= 3);
            auto c = pop();
            auto b = pop();
            auto a = pop();
            stack ~= typeTable.getMember_(pos, a.type(), "opIndexSet")
                .call(pos, env, a, b, c);
        } break;
        case OPCode.Return: {
            assert(len >= 1);
            return pop();
        }
        case OPCode.LoadConst: {
            stack ~= bl.getConst(op.val).checkGetter(pos, env);//check prop probably not needed
        } break;
        case OPCode.LoadVal: {
            stack ~= env.get(pos, env, op);//.checkGetter(pos, env);
        } break;
        case OPCode.LoadLib: {
            stack ~= bl.lib.get(op.val).checkGetter(pos, env);
        } break;
        case OPCode.MakeClosure: {
            auto b = bl.man.blocks[op.val];
            Obj*[OffsetVal] caps;
            foreach (c; b.captures) {
                caps[c] = env.getPtr(c);
            }
            stack ~= objClosure(b, caps);
        } break;
        case OPCode.MakeList: {
            assert(len >= op.val);
            auto args = popN(op.val);
            stack ~= objList(args);
        } break;
        case OPCode.MakeTuple: {
            assert(len >= op.val);
            auto args = popN(op.val);
            stack ~= objTuple(args);
        } break;
        case OPCode.MakeDict: {
            assert(len >= op.val);
            auto args = popN(op.val);
            stack ~= objDict(args);
        } break;
        case OPCode.Assign: {
            assert(len >= 1);
            auto a = pop();
            stack ~= env.set(pos, env, op, a);
        } break;
        case OPCode.SetterDef: {
            assert(len >= 1);
            auto a = pop();
            stack ~= env.setterDef(pos, op, a);
        } break;
        case OPCode.GetterDef: {
            assert(len >= 1);
            auto a = pop();
            stack ~= env.getterDef(pos, op, a);
        } break;
        case OPCode.Jmp: {
            msg = format!"%d"(op.val);
            jmp(pc, op.val);
        } break;
        case OPCode.JmpIfTrueOrPop: {
            assert(len >= 1);
            auto a = stack.back();
            if (a.toBool())
                jmp(pc, op.val);
            else
                stack.popBack();
        } break;
        case OPCode.JmpIfTruePop: {
            assert(len >= 1);
            auto a = pop();
            if (a.toBool())
                jmp(pc, op.val);
        } break;
        case OPCode.JmpIfFalseOrPop: {
            assert(len >= 1);
            auto a = stack.back();
            if (!a.toBool())
                jmp(pc, op.val);
            else
                stack.popBack();
        } break;
        case OPCode.JmpIfFalsePop: {
            assert(len >= 1);
            auto a = pop();
            if (!a.toBool())
                jmp(pc, op.val);
        } break;
        case OPCode.MakeType: {
            auto tm = bl.man.types[op.val];
            Type t;
            t.creator = (p,e) =>objUserDefined(tm.name, typeTable.construct(tm.base, pos, env, []));
            t.members["toString"] = defaultToString();
            t.members["toBool"] = defaultToBool;
            t.members["opEquals"] = defaultOpEquals;
            Obj*[OffsetVal] caps;
            foreach (c; tm.captures) {
                caps[c] = env.getPtr(c);
            }

            foreach (name, b; tm.members) {
                t.members[name] = b.eval(pos, env, [], caps);
            }
            Obj funcOrClosure(Block b) {
                if (b.captures.length == 0) return objFunction(b);
                Obj*[OffsetVal] caps;
                foreach (c; b.captures) {
                    caps[c] = env.getPtr(c);
                }

                return objClosure(b, caps);
            }
            foreach (name, b; tm.methods) {
                if (name == "ctor") {
                    t.ctor = funcOrClosure(b);
                } else {
                    t.members[name] = funcOrClosure(b);
                }
            }
            import ts.objects.user_defined;
            t.members["base"] = objProperty(
                objBIFunction((Pos p, Env e, Obj[] a) => a[0].peek!UserDefined.base),
                objBIFunction((Pos p, Env e, Obj[] a) => a[0].peek!UserDefined.base = a[1]));
            foreach (name, b; tm.getters) {
                assignFuncType!(FuncType.Getter)(t.members, name, objFunction(b));
            }
            foreach (name, b; tm.setters) {
                assignFuncType!(FuncType.Setter)(t.members, name, objFunction(b));
            }
            typeTable.add(tm.name, t);
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
