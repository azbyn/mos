module ts.run;

import ts.ast.token;
import ts.ast.ast_node;
import ts.ast.parser;
import ts.misc;
import ts.stdlib;
import ts.builtin;
import ts.ir.lib;
import ts.ir.compiler;
import ts.runtime.interpreter;

/*
import ts.ast.lexer;
import ts.ir.block;
import ts.objects.obj;
 */
import ts.visualizer;
import com.log;

import stdd.conv : to;

extern (C++) int tsrun(const DToken* ptr, int len) {
    auto toks = ptr[0 .. len];
    tslog("\nToks");
    foreach (ref t; toks) {
        tslog(t.toStr());
    }
    Parser p;
    auto r = p.parse(toks);
    tslog("\nNodes:");
    foreach (n; p.nodes) {
        tslog(n.toString() /*.to!tsstring*/ );
    }
     if(!r){
        foreach (e; p.errors) {
            tsputsln(visualizeError(toks, e.pos, "Syntax Error: " ~ e.msg));
        }
        return 1;
    }
    try {
        tslog("\nIR");
        Lib lib = stdlib();
        auto man = generateIR(p.nodes, lib);
        tslog(man.toStr());

        tslog("\nOutput:");
        auto res = man.eval();
        tslog!"res = '%s'"(res.toStr);
    }
    catch (TSException e) {
        tsputsln(visualizeError(toks, e.pos, "Error: " ~ e.msg));
    }
    return 0;
}
