/**
 * This module was renamed to disambiguate the term tuple, use
 * $(MREF stdd, meta) instead.
 *
 * Copyright: Copyright Digital Mars 2005 - 2015.
 * License: $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
 * Authors:
 * Source:    $(PHOBOSSRC stdd/_typetuple.d)
 *
 * $(SCRIPT inhibitQuickIndex = 1;)
 */
module stdd.typetuple;

public import stdd.meta;

/**
 * Alternate name for $(REF AliasSeq, stdd,meta) for legacy compatibility.
 */
alias TypeTuple = AliasSeq;

///
@safe unittest
{
    import stdd.typetuple;
    alias TL = TypeTuple!(int, double);

    int foo(TL td)  // same as int foo(int, double);
    {
        return td[0] + cast(int) td[1];
    }
}

///
@safe unittest
{
    alias TL = TypeTuple!(int, double);

    alias Types = TypeTuple!(TL, char);
    static assert(is(Types == TypeTuple!(int, double, char)));
}
