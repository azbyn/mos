module ts.ast.ast_node;

import stdd.format;
import ts.misc : FuncType;
import ts.ast.token;

private enum types = [
    "Comma", "ReverseComma", "String", "Int", "Float", "Bool", "Nil", "Variable",
    "FuncCall", "Binary", "Lambda", "Assign", "Subscript", "Member", "And", "Or",
    "If", "While", "For", "Body", "Cmp", "Return", "List", "CtrlFlow", "Dict",
    "Tuple", "SetterDef", "GetterDef", "Property", "Module", "Cat", "Struct", "This"
];

class AstNode {
    import stdd.variant;

    struct Nil {
    }
    struct This {}

    struct Comma { // evaluate a and b, return b
        AstNode a;
        AstNode b;
    }

    struct ReverseComma { // evaluate a and b, return a
        AstNode a;
        AstNode b;
    }

    struct String {
        tsstring val;
    }

    alias Int = tsint;
    alias Float = tsfloat;
    alias Bool = bool;

    struct Cmp {
        TT op;
        AstNode a;
        AstNode b;
    }

    struct Binary {
        tsstring name;
        AstNode a;
        AstNode b;
    }

    struct Variable {
        tsstring name;
    }

    struct FuncCall {
        AstNode func;
        AstNode[] args;
    }

    struct Cat {
        AstNode a;
        AstNode b;
    }

    struct Lambda {
        tsstring[] captures;
        tsstring[] params;
        bool isVariadic;
        AstNode body_;
        this(tsstring[] params, AstNode body_, bool isVariadic = false) {
            this.params = params;
            this.captures = body_.freeVars(params);
            this.body_ = body_;
            this.isVariadic = isVariadic;
        }

        this(tsstring[] captures, tsstring[] params, AstNode body_, bool isVariadic = false) {
            this.params = params;
            this.captures = captures;
            this.body_ = body_;
            this.isVariadic = isVariadic;
        }
    }

    struct Assign {
        AstNode rvalue;
        AstNode lvalue;
    }

    struct SetterDef {
        tsstring name;
        AstNode val;
    }

    struct GetterDef {
        tsstring name;
        AstNode val;
    }

    struct Property /*Def*/ {
        //tsstring name;
        AstNode get;
        AstNode set;
    }

    struct Subscript {
        AstNode val;
        AstNode index;
    }

    struct Member {
        AstNode val;
        tsstring member;
    }

    struct And {
        AstNode a;
        AstNode b;
    }

    struct Or {
        AstNode a;
        AstNode b;
    }

    struct If {
        AstNode cond;
        AstNode body_;
        AstNode else_;
    }

    struct While {
        AstNode cond;
        AstNode body_;
    }

    struct For {
        tsstring index;
        tsstring val;
        AstNode collection;
        AstNode body_;
    }

    struct Body {
        AstNode[] val;
    }

    struct Return {
        AstNode val;
    }

    struct CtrlFlow {
        TT type;
    }

    struct List {
        AstNode[] val;
    }

    struct Tuple {
        AstNode[] val;
    }

    struct Dict {
        AstNode[] val;
    }

    struct Module {
        tsstring name;
        AstNode[tsstring] members;
    }

    struct Struct {
        tsstring name;
        AstNode ctor;
        AstNode[tsstring] statics;
        AstNode[tsstring] instance;
    }

    private static string genVal() {
        string r = "Algebraic!(";
        static foreach (t; types)
            r ~= t ~ ",";
        return r ~ ") val;";
    }

    mixin(genVal());
    Pos pos;
    T* peek(T)() {
        return val.peek!T;
    }

    this(T)(Pos pos, T val) {
        this.val = val;
        this.pos = pos;
    }

    private void freeVarsTail(ref tsstring[] res, tsstring[] bound) {
        void fv(AstNode[] nodes...) {
            foreach (n; nodes) {
                n.freeVarsTail(res, bound);
            }
        }

        void add(tsstring v) {
            import ts.misc;

            if (res.contains(v) || bound.contains(v))
                return;
            res ~= v;
        }

        void fv_(AstNode[tsstring] nodes) {
            foreach (name, m; nodes) {
                add(name);
                m.freeVarsTail(res, bound);
            }
        }

        //dfmt off
        val.visit!(
            (Cmp v) { fv(v.a, v.b); },
            (Comma v) {fv(v.a, v.b); },
            (ReverseComma v) { fv(v.a, v.b); },
            (String v) {},
            (Float v) {},
            (Int v) {},
            (Bool v) {},
            (Nil v) {},
            (This v) {},
            (Variable v) { add(v.name); },
            (FuncCall v) { fv(v.func); fv(v.args); },
            (Binary v) { fv(v.a, v.b); },
            (Lambda v) { res ~= v.body_.freeVars(bound ~ v.params); },
            (Assign v) { fv(v.rvalue, v.lvalue); },
            (SetterDef v) { fv(v.val); },
            (GetterDef v) { fv(v.val); },
            (Subscript v) { fv(v.val, v.index); },
            (Member v) { fv(v.val); },
            (Module v) { add(v.name); fv_(v.members); },
            (Struct v) { add(v.name); fv_(v.statics); fv_(v.instance); },
            (And v) { fv(v.a, v.b); },
            (Or v) { fv(v.a, v.b); },
            (If v) { fv(v.cond, v.body_, v.else_); },
            (While v) { fv(v.cond, v.body_); },
            (For v) { add(v.index); add(v.val); fv(v.collection, v.body_); },
            (Body v) { fv(v.val); },
            (Dict v) { fv(v.val); },
            (List v) { fv(v.val);},
            (Tuple v) { fv(v.val);},
            (Return v) { fv(v.val); },
            (CtrlFlow v) {},
            (Cat v) { fv(v.a, v.b); },
            (Property v) { fv(v.get, v.set); },
        )();
        //dfmt on
    }

    tsstring[] freeVars(tsstring[] bound = []) {
        tsstring[] res;
        freeVarsTail(res, bound);
        return res;
    }

    override string toString() {
        import stdd.conv : to;

        return toString(0);
    }

    string toString(int level) {
        import stdd.conv : to;
        import stdd.algorithm.iteration;

        string indent = "";
        for (int i = 0; i < level - 1; ++i) {
            indent ~= "  "; //"    ";
        }
        if (level > 0)
            indent ~= "| ";
        string strSeparated(AstNode[] args, string sep, int level = 0) {
            string r = "";
            foreach (a; args) {
                r ~= a.toString(level) ~ sep;
            }
            return r;
        }

        ++level;
        string str(AstNode[] args...) {
            string r = "";
            foreach (a; args) {
                r ~= "\n" ~ (a is null ? "null" : a.toString(level));
            }
            return r;
        }

        string str_(string name, AstNode[tsstring] args) {
            string r = format!"%s  =%s:\n"(indent, name);
            foreach (name, a; args) {
                r ~= format!"\n %s:%s"(name, a is null ? "null" : a.toString(level + 1));
            }
            return r;
        }

        //dfmt off
        return indent ~ "-" ~ val.visit!(
            (Cat v) => format!"cat:%s"(str(v.a, v.b)),
            (Cmp v) => format!"cmp '%s':%s"(v.op.symbolicStr, str(v.a, v.b)),
            (Comma v) => format!"comma:%s"(str(v.a, v.b)),
            (ReverseComma v) => format!"reverseComma:%s"(str(v.a, v.b)),
            (String v) => format!`string "%s"`(v.val),
            (Float v) => format!"float %f"(v),
            (Int v) => format!"int %d"(v),
            (Bool v) => format!"bool %s"(v),
            (Nil v) => "nil",
            (This v) => "this",
            (Variable v) => format!"variable '%s'"(v.name),
            (FuncCall v) => format!"funcCall:%s%s"(str(v.func), str(v.args)),
            (Binary v) => format!"binary '%s':%s"(v.name, str(v.a, v.b)),
            (Lambda v) => format!"lambda (%s%s) [%s]:%s"(v.params.joiner(","),
                                                         v.isVariadic?"...":"", v.captures.joiner(","), str(v.body_)),
            (Assign v) => format!"assign:%s"(str(v.rvalue, v.lvalue)),
            (SetterDef v) => format!"setterDef %s:%s"(v.name, str(v.val)),
            (GetterDef v) => format!"getterDef %s:%s"(v.name, str(v.val)),
            (Property v) => format!"property: %s"(str(v.get, v.set)),
            (Subscript v) => format!"subscript:%s"(str(v.val, v.index)),
            (Member v) => format!"member '%s':%s"(v.member, str(v.val)),
            (And v) => format!"and:%s"(str(v.a, v.b)),
            (Or v) => format!"or:%s"(str(v.a, v.b)),
            (If v) => format!"if:%s"(str(v.cond, v.body_, v.else_)),
            (While v) => format!"while:%s"(str(v.cond, v.body_)),
            (For v) => format!"for %s, %s:%s"(v.index, v.val, str(v.collection, v.body_)),
            (Body v) => "body:" ~ str(v.val),
            (List v) => "list:" ~ str(v.val),
            (Tuple v) => "tuple:" ~ str(v.val),
            (Dict v) => "dict:" ~ str(v.val),
            (Return v) => format!"return:%s"(str(v.val)),
            (CtrlFlow v) => v.type.symbolicStr,
            (Struct v) => format!"struct %s: %s%s%s"(v.name, str(v.ctor),
                                                     str_("statics", v.statics), str_("instance", v.instance)),
            (Module v) => format!"module %s: %s"(v.name, str_("members", v.members)),
        )();
        //dfmt on
    }
}

static foreach (t; types)
    mixin(format!`AstNode ast%s(A...)(Pos pos, A args) {
                      return new AstNode(pos, AstNode.%s(args));
                  }`(t, t));

unittest {
    AstNode[] nodes;
    auto t = astFuncCall(-1, null, nodes);
    //writefln("if='%s'", astIf(-1, null, null, null).toString);
    //assert(t.args.size == 1);
}
