module ts.stdlib;

import stdd.format;

public import ts.stdlib.misc;
public import ts.stdlib.math;
public import ts.stdlib.io;

@property auto modulesInStdlib() {
    return [ "ts.stdlib.misc", "ts.stdlib.math", "ts.stdlib.io" ];
}

@property auto types() {
    static import ts.stdlib.misc;
    static import ts.stdlib.math;
    static import ts.stdlib.io;

    string[] res;
    static foreach (x; modulesInStdlib()) {
        static foreach (m; __traits(allMembers, mixin( x))) {
            static if (m== "types") {
                res ~= mixin(x~".types");
            }
        }
    }
    return res;
}
