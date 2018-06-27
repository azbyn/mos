module mos.run;

import mos.ast.token;
import mos.ast.ast_node;
import mos.ast.parser;
import mos.misc;
import mos.stdlib;
import mos.imported : stdlib;
import mos.ir.lib;
import mos.ir.compiler;
import mos.runtime.interpreter;
import mos.runtime.env;

/*
import mos.ast.lexer;
import mos.ir.block;
import mos.objects.obj;
 */
import mos.visualizer;
import com.log;

import stdd.conv : to;

extern (C++) int mosrun(const DToken* ptr, int len) {
    auto toks = ptr[0 .. len];
    moslog("\nToks");
    foreach (ref t; toks) {
        moslog(t.toStr());
        }
    Parser p;
    auto r = p.parse(toks);
    moslog("\nNodes:");
    foreach (n; p.nodes) {
        moslog(n.toString() /*.to!mosstring*/ );
    }
    if(!r){
        foreach (e; p.errors) {
            mosputsln(visualizeError(toks, e.pos, "Syntax Error: " ~ e.msg));
        }
        return 1;
    }
    version (Nothrow) {
        moslog("\nIR");
        Lib lib = stdlib;
        auto man = generateIR(p.nodes, lib);
        Env e;
        auto res = man.evalDbg(e);
        moslog!"res = '%s'"(res.toStr(Pos(-1), e));
    } else {
        try {
            moslog("\nIR");
            Lib lib = stdlib;
            auto man = generateIR(p.nodes, lib);
            Env e;
            auto res = man.evalDbg(e);
            moslog!"res = '%s'"(res.toStr(Pos(-1), e));
        }
        catch (MOSException e) {
            mosputsln(visualizeError(toks, e.pos, "Error: " ~ e.msg));
        }
    }
    return 0;
}
