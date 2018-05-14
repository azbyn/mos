// Written in the D programming language.

/**
 * This test program pulls in all the library modules in order to run the unit
 * tests on them.  Then, it prints out the arguments passed to main().
 *
 * Copyright: Copyright Digital Mars 2000 - 2009.
 * License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:   $(HTTP digitalmars.com, Walter Bright)
 *
 *          Copyright Digital Mars 2000 - 2009.
 * Distributed under the Boost Software License, Version 1.0.
 *    (See accompanying file LICENSE_1_0.txt or copy at
 *          http://www.boost.org/LICENSE_1_0.txt)
 */

public import stdd.base64;
public import stdd.compiler;
public import stdd.concurrency;
public import stdd.conv;
public import stdd.container;
public import stdd.datetime;
public import stdd.demangle;
public import stdd.file;
public import stdd.format;
public import stdd.getopt;
public import stdd.math;
public import stdd.mathspecial;
public import stdd.mmfile;
public import stdd.outbuffer;
public import stdd.parallelism;
public import stdd.path;
public import stdd.process;
public import stdd.random;
public import stdd.regex;
public import stdd.signals;
//public import stdd.slist;
public import stdd.socket;
public import stdd.stdint;
public import stdd.stdio;
public import stdd.string;
public import stdd.system;
public import stdd.traits;
public import stdd.typetuple;
public import stdd.uni;
public import stdd.uri;
public import stdd.utf;
public import stdd.uuid;
public import stdd.variant;
public import stdd.zip;
public import stdd.zlib;
public import stdd.net.isemail;
public import stdd.net.curl;
public import stdd.digest.digest;
public import stdd.digest.crc;
public import stdd.digest.sha;
public import stdd.digest.md;
public import stdd.digest.hmac;

int main(string[] args)
{
    // Bring in unit test for module by referencing function in it

    cast(void)cmp("foo", "bar");                  // string
    cast(void)filenameCharCmp('a', 'b');          // path
    cast(void)isNaN(1.0);                         // math
    stdd.conv.to!double("1.0");          // stdd.conv
    OutBuffer b = new OutBuffer();      // outbuffer
    auto r = regex("");                 // regex
    uint ranseed = stdd.random.unpredictableSeed;
    thisTid;
    int[] a;
    import stdd.algorithm.sorting : sort;
    import stdd.algorithm.mutation : reverse;
    reverse(a);                         // adi
    sort(a);                            // qsort
    Clock.currTime();                   // datetime
    cast(void)isValidDchar(cast(dchar)0);          // utf
    stdd.uri.ascii2hex(0);                // uri
    stdd.zlib.adler32(0,null);            // D.zlib
    auto t = task!cmp("foo", "bar");  // parallelism

    creal c = 3.0 + 4.0i;
    c = sqrt(c);
    assert(c.re == 2);
    assert(c.im == 1);

    printf("args.length = %d\n", args.length);
    for (int i = 0; i < args.length; i++)
        printf("args[%d] = '%.*s'\n", i, args[i].length, args[i].ptr);

    int[3] x;
    x[0] = 3;
    x[1] = 45;
    x[2] = -1;
    sort(x[]);
    assert(x[0] == -1);
    assert(x[1] == 3);
    assert(x[2] == 45);

    cast(void)stdd.math.sin(3.0);
    cast(void)stdd.mathspecial.gamma(6.2);

    stdd.demangle.demangle("hello");

    cast(void)stdd.uni.isAlpha('A');

    stdd.file.exists("foo");

    foreach_reverse (dchar d; "hello"c) { }
    foreach_reverse (k, dchar d; "hello"c) { }

    stdd.signals.linkin();

    bool isEmail = stdd.net.isemail.isEmail("abc");
    auto http = stdd.net.curl.HTTP("dlang.org");
    auto uuid = randomUUID();

    auto md5 = md5Of("hello");
    auto sha1 = sha1Of("hello");
    auto crc = crc32Of("hello");
    auto string = toHexString(crc);
    puts("Success!");
    return 0;
}
