// Written in the D programming language.

/**
Bit-level manipulation facilities.

$(SCRIPT inhibitQuickIndex = 1;)
$(BOOKTABLE,
$(TR $(TH Category) $(TH Functions))
$(TR $(TD Bit constructs) $(TD
    $(LREF BitArray)
    $(LREF bitfields)
    $(LREF bitsSet)
))
$(TR $(TD Endianness conversion) $(TD
    $(LREF bigEndianToNative)
    $(LREF littleEndianToNative)
    $(LREF nativeToBigEndian)
    $(LREF nativeToLittleEndian)
    $(LREF swapEndian)
))
$(TR $(TD Integral ranges) $(TD
    $(LREF append)
    $(LREF peek)
    $(LREF read)
    $(LREF write)
))
$(TR $(TD Floating-Point manipulation) $(TD
    $(LREF DoubleRep)
    $(LREF FloatRep)
))
$(TR $(TD Tagging) $(TD
    $(LREF taggedClassRef)
    $(LREF taggedPointer)
))
)

Copyright: Copyright Digital Mars 2007 - 2011.
License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   $(HTTP digitalmars.com, Walter Bright),
           $(HTTP erdani.org, Andrei Alexandrescu),
           $(HTTP jmdavisprog.com, Jonathan M Davis),
           Alex Rønne Petersen,
           Damian Ziemba,
           Amaury SECHET
Source: $(PHOBOSSRC stdd/_bitmanip.d)
*/
/*
         Copyright Digital Mars 2007 - 2012.
Distributed under the Boost Software License, Version 1.0.
   (See accompanying file LICENSE_1_0.txt or copy at
         http://www.boost.org/LICENSE_1_0.txt)
*/
module stdd.bitmanip;

import stdd.range.primitives;
public import stdd.system : Endian;
import stdd.traits;
private string myToString(ulong n)
{
    import core.internal.string : UnsignedStringBuf, unsignedToTempString;
    UnsignedStringBuf buf;
    auto s = unsignedToTempString(n, buf);
    return cast(string) s ~ (n > uint.max ? "UL" : "U");
}

private template createAccessors(
    string store, T, string name, size_t len, size_t offset)
{
    static if (!name.length)
    {
        // No need to create any accessor
        enum result = "";
    }
    else static if (len == 0)
    {
        // Fields of length 0 are always zero
        enum result = "enum "~T.stringof~" "~name~" = 0;\n";
    }
    else
    {
        enum ulong
            maskAllElse = ((~0uL) >> (64 - len)) << offset,
            signBitCheck = 1uL << (len - 1);

        static if (T.min < 0)
        {
            enum long minVal = -(1uL << (len - 1));
            enum ulong maxVal = (1uL << (len - 1)) - 1;
            alias UT = Unsigned!(T);
            enum UT extendSign = cast(UT)~((~0uL) >> (64 - len));
        }
        else
        {
            enum ulong minVal = 0;
            enum ulong maxVal = (~0uL) >> (64 - len);
            enum extendSign = 0;
        }

        static if (is(T == bool))
        {
            static assert(len == 1, "`" ~ name ~
                    "` definition problem: type `bool` is only allowed for single-bit fields");
            enum result =
            // getter
                "@property bool " ~ name ~ "() @safe pure nothrow @nogc const { return "
                ~"("~store~" & "~myToString(maskAllElse)~") != 0;}\n"
            // setter
                ~"@property void " ~ name ~ "(bool v) @safe pure nothrow @nogc { "
                ~"if (v) "~store~" |= "~myToString(maskAllElse)~";"
                ~"else "~store~" &= cast(typeof("~store~"))(-1-cast(typeof("~store~"))"~myToString(maskAllElse)~");}\n";
        }
        else
        {
            // getter
            enum result = "@property "~T.stringof~" "~name~"() @safe pure nothrow @nogc const { auto result = "
                ~"("~store~" & "
                ~ myToString(maskAllElse) ~ ") >>"
                ~ myToString(offset) ~ ";"
                ~ (T.min < 0
                   ? "if (result >= " ~ myToString(signBitCheck)
                   ~ ") result |= " ~ myToString(extendSign) ~ ";"
                   : "")
                ~ " return cast("~T.stringof~") result;}\n"
            // setter
                ~"@property void "~name~"("~T.stringof~" v) @safe pure nothrow @nogc { "
                ~"assert(v >= "~name~`_min, "Value is smaller than the minimum value of bitfield '`~name~`'"); `
                ~"assert(v <= "~name~`_max, "Value is greater than the maximum value of bitfield '`~name~`'"); `
                ~store~" = cast(typeof("~store~"))"
                ~" (("~store~" & (-1-cast(typeof("~store~"))"~myToString(maskAllElse)~"))"
                ~" | ((cast(typeof("~store~")) v << "~myToString(offset)~")"
                ~" & "~myToString(maskAllElse)~"));}\n"
            // constants
                ~"enum "~T.stringof~" "~name~"_min = cast("~T.stringof~")"
                ~myToString(minVal)~"; "
                ~" enum "~T.stringof~" "~name~"_max = cast("~T.stringof~")"
                ~myToString(maxVal)~"; ";
        }
    }
}

private template createStoreName(Ts...)
{
    static if (Ts.length < 2)
        enum createStoreName = "";
    else
        enum createStoreName = "_" ~ Ts[1] ~ createStoreName!(Ts[3 .. $]);
}

private template createStorageAndFields(Ts...)
{
    enum Name = createStoreName!Ts;
    enum Size = sizeOfBitField!Ts;
    static if (Size == ubyte.sizeof * 8)
        alias StoreType = ubyte;
    else static if (Size == ushort.sizeof * 8)
        alias StoreType = ushort;
    else static if (Size == uint.sizeof * 8)
        alias StoreType = uint;
    else static if (Size == ulong.sizeof * 8)
        alias StoreType = ulong;
    else
    {
        static assert(false, "Field widths must sum to 8, 16, 32, or 64");
        alias StoreType = ulong; // just to avoid another error msg
    }
    enum result
        = "private " ~ StoreType.stringof ~ " " ~ Name ~ ";"
        ~ createFields!(Name, 0, Ts).result;
}

private template createFields(string store, size_t offset, Ts...)
{
    static if (Ts.length > 0)
        enum result
            = createAccessors!(store, Ts[0], Ts[1], Ts[2], offset).result
            ~ createFields!(store, offset + Ts[2], Ts[3 .. $]).result;
    else
        enum result = "";
}

private ulong getBitsForAlign(ulong a)
{
    ulong bits = 0;
    while ((a & 0x01) == 0)
    {
        bits++;
        a >>= 1;
    }

    assert(a == 1, "alignment is not a power of 2");
    return bits;
}

private template createReferenceAccessor(string store, T, ulong bits, string name)
{
    enum storage = "private void* " ~ store ~ "_ptr;\n";
    enum storage_accessor = "@property ref size_t " ~ store ~ "() return @trusted pure nothrow @nogc const { "
        ~ "return *cast(size_t*) &" ~ store ~ "_ptr;}\n"
        ~ "@property void " ~ store ~ "(size_t v) @trusted pure nothrow @nogc { "
        ~ "" ~ store ~ "_ptr = cast(void*) v;}\n";

    enum mask = (1UL << bits) - 1;
    // getter
    enum ref_accessor = "@property "~T.stringof~" "~name~"() @trusted pure nothrow @nogc const { auto result = "
        ~ "("~store~" & "~myToString(~mask)~"); "
        ~ "return cast("~T.stringof~") cast(void*) result;}\n"
    // setter
        ~"@property void "~name~"("~T.stringof~" v) @trusted pure nothrow @nogc { "
        ~"assert(((cast(typeof("~store~")) cast(void*) v) & "~myToString(mask)
        ~`) == 0, "Value not properly aligned for '`~name~`'"); `
        ~store~" = cast(typeof("~store~"))"
        ~" (("~store~" & (cast(typeof("~store~")) "~myToString(mask)~"))"
        ~" | ((cast(typeof("~store~")) cast(void*) v) & (cast(typeof("~store~")) "~myToString(~mask)~")));}\n";

    enum result = storage ~ storage_accessor ~ ref_accessor;
}

private template sizeOfBitField(T...)
{
    static if (T.length < 2)
        enum sizeOfBitField = 0;
    else
        enum sizeOfBitField = T[2] + sizeOfBitField!(T[3 .. $]);
}

private template createTaggedReference(T, ulong a, string name, Ts...)
{
    static assert(
        sizeOfBitField!Ts <= getBitsForAlign(a),
        "Fields must fit in the bits know to be zero because of alignment."
    );
    enum StoreName = createStoreName!(T, name, 0, Ts);
    enum result
        = createReferenceAccessor!(StoreName, T, sizeOfBitField!Ts, name).result
        ~ createFields!(StoreName, 0, Ts, size_t, "", T.sizeof * 8 - sizeOfBitField!Ts).result;
}

/**
Allows creating bit fields inside $(D_PARAM struct)s and $(D_PARAM
class)es.

The type of a bit field can be any integral type or enumerated
type. The most efficient type to store in bitfields is $(D_PARAM
bool), followed by unsigned types, followed by signed types.

See_Also: $(REF BitFlags, stdd,typecons)
*/

template bitfields(T...)
{
    enum { bitfields = createStorageAndFields!T.result }
}

template taggedPointer(T : T*, string name, Ts...) {
    enum taggedPointer = createTaggedReference!(T*, T.alignof, name, Ts).result;
}
/**
This string mixin generator allows one to create tagged class reference inside $(D_PARAM struct)s and $(D_PARAM class)es.

A tagged class reference uses the bits known to be zero in a normal class reference to store extra information.
For example, a pointer to an integer must be 4-byte aligned, so there are 2 bits that are always known to be zero.
One can store a 2-bit integer there.

The example above creates a tagged reference to an Object in the struct A. This expects the same parameters
as `taggedPointer`, except the first argument which must be a class type instead of a pointer type.
*/

template taggedClassRef(T, string name, Ts...)
if (is(T == class))
{
    enum taggedClassRef = createTaggedReference!(T, 8, name, Ts).result;
}
/+
struct FloatRep
{
    union
    {
        float value;
        mixin(bitfields!(
                  uint,  "fraction", 23,
                  ubyte, "exponent",  8,
                  bool,  "sign",      1));
    }
    enum uint bias = 127, fractionBits = 23, exponentBits = 8, signBits = 1;
}


struct DoubleRep
{
    union
    {
        double value;
        mixin(bitfields!(
                  ulong,  "fraction", 52,
                  ushort, "exponent", 11,
                  bool,   "sign",      1));
    }
    enum uint bias = 1023, signBits = 1, fractionBits = 52, exponentBits = 11;
}
/**
A dynamic array of bits. Each bit in a `BitArray` can be manipulated individually
or by the standard bitwise operators `&`, `|`, `^`, `~`, `>>`, `<<` and also by
other effective member functions; most of them work relative to the `BitArray`'s
dimension (see $(LREF dim)), instead of its $(LREF length).
*/
struct BitArray
{
private:

    import core.bitop : btc, bts, btr, bsf, bt;
    import stdd.format : FormatSpec;

    size_t _len;
    size_t* _ptr;
    enum bitsPerSizeT = size_t.sizeof * 8;

    @property size_t fullWords() const @nogc pure nothrow
    {
        return _len / bitsPerSizeT;
    }
    // Number of bits after the last full word
    @property size_t endBits() const @nogc pure nothrow
    {
        return _len % bitsPerSizeT;
    }
    // Bit mask to extract the bits after the last full word
    @property size_t endMask() const @nogc pure nothrow
    {
        return (size_t(1) << endBits) - 1;
    }
    static size_t lenToDim(size_t len) @nogc pure nothrow @safe
    {
        return (len + (bitsPerSizeT-1)) / bitsPerSizeT;
    }

public:
    /**
    Creates a `BitArray` from a `bool` array, such that `bool` values read
    from left to right correspond to subsequent bits in the `BitArray`.

    Params: ba = Source array of `bool` values.
    */
    this(in bool[] ba) nothrow pure
    {
        length = ba.length;
        foreach (i, b; ba)
        {
            this[i] = b;
        }
    }

    /**
    Creates a `BitArray` from the raw contents of the source array. The
    source array is not copied but simply acts as the underlying array
    of bits, which stores data as `size_t` units.

    That means a particular care should be taken when passing an array
    of a type different than `size_t`, firstly because its length should
    be a multiple of `size_t.sizeof`, and secondly because how the bits
    are mapped:
    ---
    size_t[] source = [1, 2, 3, 3424234, 724398, 230947, 389492];
    enum sbits = size_t.sizeof * 8;
    auto ba = BitArray(source, source.length * sbits);
    foreach (n; 0 .. source.length * sbits)
    {
        auto nth_bit = cast(bool) (source[n / sbits] & (1L << (n % sbits)));
        assert(ba[n] == nth_bit);
    }
    ---
    The least significant bit in any `size_t` unit is the starting bit of this
    unit, and the most significant bit is the last bit of this unit. Therefore,
    passing e.g. an array of `int`s may result in a different `BitArray`
    depending on the processor's endianness.

    This constructor is the inverse of $(LREF opCast).

    $(RED Warning: All unmapped bits in the final word will be set to 0.)

    Params:
        v = Source array. `v.length` must be a multple of `size_t.sizeof`.
        numbits = Number of bits to be mapped from the source array, i.e.
                  length of the created `BitArray`.
    */
    this(void[] v, size_t numbits) @nogc nothrow pure
    in
    {
        assert(numbits <= v.length * 8);
        assert(v.length % size_t.sizeof == 0);
    }
    do
    {
        _ptr = cast(size_t*) v.ptr;
        _len = numbits;
        if (endBits)
        {
            // Need to mask away extraneous bits from v.
            _ptr[dim - 1] &= endMask;
        }
    }

    // Deliberately undocumented: raw initialization of bit array.
    this(size_t len, size_t* ptr) @nogc nothrow pure
    {
        _len = len;
        _ptr = ptr;
    }

    /**
    Returns: Dimension i.e. the number of native words backing this `BitArray`.

    Technically, this is the length of the underlying array storing bits, which
    is equal to `ceil(length / (size_t.sizeof * 8))`, as bits are packed into
    `size_t` units.
    */
    @property size_t dim() const @nogc nothrow pure @safe
    {
        return lenToDim(_len);
    }

    /**
    Returns: Number of bits in the `BitArray`.
    */
    @property size_t length() const @nogc nothrow pure @safe
    {
        return _len;
    }

    /**********************************************
     * Sets the amount of bits in the `BitArray`.
     * $(RED Warning: increasing length may overwrite bits in
     * final word up to the next word boundary. i.e. D dynamic
     * array extension semantics are not followed.)
     */
    @property size_t length(size_t newlen) pure nothrow @system
    {
        if (newlen != _len)
        {
            size_t olddim = dim;
            immutable newdim = lenToDim(newlen);

            if (newdim != olddim)
            {
                // Create a fake array so we can use D's realloc machinery
                auto b = _ptr[0 .. olddim];
                b.length = newdim;                // realloc
                _ptr = b.ptr;
            }

            _len = newlen;
        }
        return _len;
    }

    /**********************************************
     * Gets the `i`'th bit in the `BitArray`.
     */
    bool opIndex(size_t i) const @nogc pure nothrow
    in
    {
        assert(i < _len);
    }
    do
    {
        return cast(bool) bt(_ptr, i);
    }

    ///
    @system unittest
    {
        static void fun(const BitArray arr)
        {
            auto x = arr[0];
            assert(x == 1);
        }
        BitArray a;
        a.length = 3;
        a[0] = 1;
        fun(a);
    }

    /**********************************************
     * Sets the `i`'th bit in the `BitArray`.
     */
    bool opIndexAssign(bool b, size_t i) @nogc pure nothrow
    in
    {
        assert(i < _len);
    }
    do
    {
        if (b)
            bts(_ptr, i);
        else
            btr(_ptr, i);
        return b;
    }

    /**
      Sets all the values in the `BitArray` to the
      value specified by `val`.
     */
    void opSliceAssign(bool val)
    {
        _ptr[0 .. fullWords] = val ? ~size_t(0) : 0;
        if (endBits)
        {
            if (val)
                _ptr[fullWords] |= endMask;
            else
                _ptr[fullWords] &= ~endMask;
        }
    }


    /**
      Sets the bits of a slice of `BitArray` starting
      at index `start` and ends at index ($D end - 1)
      with the values specified by `val`.
     */
    void opSliceAssign(bool val, size_t start, size_t end)
    in
    {
        assert(start <= end);
        assert(end <= length);
    }
    do
    {
        size_t startBlock = start / bitsPerSizeT;
        size_t endBlock = end / bitsPerSizeT;
        size_t startOffset = start % bitsPerSizeT;
        size_t endOffset = end % bitsPerSizeT;

        if (startBlock == endBlock)
        {
            size_t startBlockMask = ~((size_t(1) << startOffset) - 1);
            size_t endBlockMask = (size_t(1) << endOffset) - 1;
            size_t joinMask = startBlockMask & endBlockMask;
            if (val)
                _ptr[startBlock] |= joinMask;
            else
                _ptr[startBlock] &= ~joinMask;
            return;
        }

        if (startOffset != 0)
        {
            size_t startBlockMask = ~((size_t(1) << startOffset) - 1);
            if (val)
                _ptr[startBlock] |= startBlockMask;
            else
                _ptr[startBlock] &= ~startBlockMask;
            ++startBlock;
        }
        if (endOffset != 0)
        {
            size_t endBlockMask = (size_t(1) << endOffset) - 1;
            if (val)
                _ptr[endBlock] |= endBlockMask;
            else
                _ptr[endBlock] &= ~endBlockMask;
        }
        _ptr[startBlock .. endBlock] = size_t(0) - size_t(val);
    }

    /**
      Flips all the bits in the `BitArray`
     */
    void flip()
    {
        foreach (i; 0 .. fullWords)
            _ptr[i] = ~_ptr[i];

        if (endBits)
            _ptr[fullWords] = (~_ptr[fullWords]) & endMask;
    }

    void flip(size_t i)
    {
        bt(_ptr, i) ? btr(_ptr, i) : bts(_ptr, i);
    }

    /**********************************************
     * Counts all the set bits in the `BitArray`
     */
    size_t count()
    {
        size_t bitCount;
        foreach (i; 0 .. fullWords)
            bitCount += countBitsSet(_ptr[i]);
        bitCount += countBitsSet(_ptr[fullWords] & endMask);
        return bitCount;
    }

    /**********************************************
     * Duplicates the `BitArray` and its contents.
     */
    @property BitArray dup() const pure nothrow
    {
        BitArray ba;

        auto b = _ptr[0 .. dim].dup;
        ba._len = _len;
        ba._ptr = b.ptr;
        return ba;
    }

    /**********************************************
     * Support for `foreach` loops for `BitArray`.
     */
    int opApply(scope int delegate(ref bool) dg)
    {
        int result;

        foreach (i; 0 .. _len)
        {
            bool b = opIndex(i);
            result = dg(b);
            this[i] = b;
            if (result)
                break;
        }
        return result;
    }

    /** ditto */
    int opApply(scope int delegate(bool) dg) const
    {
        int result;

        foreach (i; 0 .. _len)
        {
            immutable b = opIndex(i);
            result = dg(b);
            if (result)
                break;
        }
        return result;
    }

    /** ditto */
    int opApply(scope int delegate(size_t, ref bool) dg)
    {
        int result;

        foreach (i; 0 .. _len)
        {
            bool b = opIndex(i);
            result = dg(i, b);
            this[i] = b;
            if (result)
                break;
        }
        return result;
    }

    /** ditto */
    int opApply(scope int delegate(size_t, bool) dg) const
    {
        int result;

        foreach (i; 0 .. _len)
        {
            immutable b = opIndex(i);
            result = dg(i, b);
            if (result)
                break;
        }
        return result;
    }


    /**********************************************
     * Reverses the bits of the `BitArray`.
     */
    @property BitArray reverse() @nogc pure nothrow
    out (result)
    {
        assert(result == this);
    }
    do
    {
        if (_len >= 2)
        {
            bool t;
            size_t lo, hi;

            lo = 0;
            hi = _len - 1;
            for (; lo < hi; lo++, hi--)
            {
                t = this[lo];
                this[lo] = this[hi];
                this[hi] = t;
            }
        }
        return this;
    }


    /**********************************************
     * Sorts the `BitArray`'s elements.
     */
    @property BitArray sort() @nogc pure nothrow
    out (result)
    {
        assert(result == this);
    }
    do
    {
        if (_len >= 2)
        {
            size_t lo, hi;

            lo = 0;
            hi = _len - 1;
            while (1)
            {
                while (1)
                {
                    if (lo >= hi)
                        goto Ldone;
                    if (this[lo] == true)
                        break;
                    lo++;
                }

                while (1)
                {
                    if (lo >= hi)
                        goto Ldone;
                    if (this[hi] == false)
                        break;
                    hi--;
                }

                this[lo] = false;
                this[hi] = true;

                lo++;
                hi--;
            }
        }
    Ldone:
        return this;
    }


    /***************************************
     * Support for operators == and != for `BitArray`.
     */
    bool opEquals(const ref BitArray a2) const @nogc pure nothrow
    {
        if (this.length != a2.length)
            return false;
        auto p1 = this._ptr;
        auto p2 = a2._ptr;

        if (p1[0 .. fullWords] != p2[0 .. fullWords])
            return false;

        if (!endBits)
            return true;

        auto i = fullWords;
        return (p1[i] & endMask) == (p2[i] & endMask);
    }
    /***************************************
     * Supports comparison operators for `BitArray`.
     */
    int opCmp(BitArray a2) const @nogc pure nothrow
    {
        const lesser = this.length < a2.length ? &this : &a2;
        immutable fullWords = lesser.fullWords;
        immutable endBits = lesser.endBits;
        auto p1 = this._ptr;
        auto p2 = a2._ptr;

        foreach (i; 0 .. fullWords)
        {
            if (p1[i] != p2[i])
            {
                return p1[i] & (size_t(1) << bsf(p1[i] ^ p2[i])) ? 1 : -1;
            }
        }

        if (endBits)
        {
            immutable i = fullWords;
            immutable diff = p1[i] ^ p2[i];
            if (diff)
            {
                immutable index = bsf(diff);
                if (index < endBits)
                {
                    return p1[i] & (size_t(1) << index) ? 1 : -1;
                }
            }
        }

        // Standard:
        // A bool value can be implicitly converted to any integral type,
        // with false becoming 0 and true becoming 1
        return (this.length > a2.length) - (this.length < a2.length);
    }


    /***************************************
     * Support for hashing for `BitArray`.
     */
    size_t toHash() const @nogc pure nothrow
    {
        size_t hash = 3557;
        auto fullBytes = _len / 8;
        foreach (i; 0 .. fullBytes)
        {
            hash *= 3559;
            hash += (cast(byte*) this._ptr)[i];
        }
        foreach (i; 8*fullBytes .. _len)
        {
            hash *= 3571;
            hash += this[i];
        }
        return hash;
    }

    /***************************************
     * Convert to `void[]`.
     */
    void[] opCast(T : void[])() @nogc pure nothrow
    {
        return cast(void[])_ptr[0 .. dim];
    }

    /***************************************
     * Convert to `size_t[]`.
     */
    size_t[] opCast(T : size_t[])() @nogc pure nothrow
    {
        return _ptr[0 .. dim];
    }

    ///

    /***************************************
     * Support for unary operator ~ for `BitArray`.
     */
    BitArray opCom() const pure nothrow
    {
        auto dim = this.dim;

        BitArray result;
        result.length = _len;

        result._ptr[0 .. dim] = ~this._ptr[0 .. dim];

        // Avoid putting garbage in extra bits
        // Remove once we zero on length extension
        if (endBits)
            result._ptr[dim - 1] &= endMask;

        return result;
    }


    /***************************************
     * Support for binary bitwise operators for `BitArray`.
     */
    BitArray opBinary(string op)(const BitArray e2) const pure nothrow
        if (op == "-" || op == "&" || op == "|" || op == "^")
    in
    {
        assert(_len == e2.length);
    }
    do
    {
        auto dim = this.dim;

        BitArray result;
        result.length = _len;

        static if (op == "-")
            result._ptr[0 .. dim] = this._ptr[0 .. dim] & ~e2._ptr[0 .. dim];
        else
            mixin("result._ptr[0 .. dim] = this._ptr[0 .. dim]"~op~" e2._ptr[0 .. dim];");

        // Avoid putting garbage in extra bits
        // Remove once we zero on length extension
        if (endBits)
            result._ptr[dim - 1] &= endMask;

        return result;
    }
    /***************************************
     * Support for operator op= for `BitArray`.
     */
    BitArray opOpAssign(string op)(const BitArray e2) @nogc pure nothrow
        if (op == "-" || op == "&" || op == "|" || op == "^")
    in
    {
        assert(_len == e2.length);
    }
    do
    {
        foreach (i; 0 .. fullWords)
        {
            static if (op == "-")
                _ptr[i] &= ~e2._ptr[i];
            else
                mixin("_ptr[i] "~op~"= e2._ptr[i];");
        }
        if (!endBits)
            return this;

        size_t i = fullWords;
        size_t endWord = _ptr[i];
        static if (op == "-")
            endWord &= ~e2._ptr[i];
        else
            mixin("endWord "~op~"= e2._ptr[i];");
        _ptr[i] = (_ptr[i] & ~endMask) | (endWord & endMask);

        return this;
    }


    /***************************************
     * Support for operator ~= for `BitArray`.
     * $(RED Warning: This will overwrite a bit in the final word
     * of the current underlying data regardless of whether it is
     * shared between BitArray objects. i.e. D dynamic array
     * concatenation semantics are not followed)
     */

    BitArray opCatAssign(bool b) pure nothrow
    {
        length = _len + 1;
        this[_len - 1] = b;
        return this;
    }


    /***************************************
     * ditto
     */

    BitArray opCatAssign(BitArray b) pure nothrow
    {
        auto istart = _len;
        length = _len + b.length;
        for (auto i = istart; i < _len; i++)
            this[i] = b[i - istart];
        return this;
    }

    ///

    /***************************************
     * Support for binary operator ~ for `BitArray`.
     */
    BitArray opCat(bool b) const pure nothrow
    {
        BitArray r;

        r = this.dup;
        r.length = _len + 1;
        r[_len] = b;
        return r;
    }

    /** ditto */
    BitArray opCat_r(bool b) const pure nothrow
    {
        BitArray r;

        r.length = _len + 1;
        r[0] = b;
        foreach (i; 0 .. _len)
            r[1 + i] = this[i];
        return r;
    }

    /** ditto */
    BitArray opCat(BitArray b) const pure nothrow
    {
        BitArray r;

        r = this.dup;
        r ~= b;
        return r;
    }

    // Rolls double word (upper, lower) to the right by n bits and returns the
    // lower word of the result.
    private static size_t rollRight()(size_t upper, size_t lower, size_t nbits)
        pure @safe nothrow @nogc
    in
    {
        assert(nbits < bitsPerSizeT);
    }
    do
    {
        if (nbits == 0)
            return lower;
        return (upper << (bitsPerSizeT - nbits)) | (lower >> nbits);
    }

    // Rolls double word (upper, lower) to the left by n bits and returns the
    // upper word of the result.
    private static size_t rollLeft()(size_t upper, size_t lower, size_t nbits)
        pure @safe nothrow @nogc
    in
    {
        assert(nbits < bitsPerSizeT);
    }
    do
    {
        if (nbits == 0)
            return upper;
        return (upper << nbits) | (lower >> (bitsPerSizeT - nbits));
    }


    /**
     * Operator `<<=` support.
     *
     * Shifts all the bits in the array to the left by the given number of
     * bits.  The leftmost bits are dropped, and 0's are appended to the end
     * to fill up the vacant bits.
     *
     * $(RED Warning: unused bits in the final word up to the next word
     * boundary may be overwritten by this operation. It does not attempt to
     * preserve bits past the end of the array.)
     */
    void opOpAssign(string op)(size_t nbits) @nogc pure nothrow
        if (op == "<<")
    {
        size_t wordsToShift = nbits / bitsPerSizeT;
        size_t bitsToShift = nbits % bitsPerSizeT;

        if (wordsToShift < dim)
        {
            foreach_reverse (i; 1 .. dim - wordsToShift)
            {
                _ptr[i + wordsToShift] = rollLeft(_ptr[i], _ptr[i-1],
                                                 bitsToShift);
            }
            _ptr[wordsToShift] = rollLeft(_ptr[0], 0, bitsToShift);
        }

        import stdd.algorithm.comparison : min;
        foreach (i; 0 .. min(wordsToShift, dim))
        {
            _ptr[i] = 0;
        }
    }

    /**
     * Operator `>>=` support.
     *
     * Shifts all the bits in the array to the right by the given number of
     * bits.  The rightmost bits are dropped, and 0's are inserted at the back
     * to fill up the vacant bits.
     *
     * $(RED Warning: unused bits in the final word up to the next word
     * boundary may be overwritten by this operation. It does not attempt to
     * preserve bits past the end of the array.)
     */
    void opOpAssign(string op)(size_t nbits) @nogc pure nothrow
        if (op == ">>")
    {
        size_t wordsToShift = nbits / bitsPerSizeT;
        size_t bitsToShift = nbits % bitsPerSizeT;

        if (wordsToShift + 1 < dim)
        {
            foreach (i; 0 .. dim - wordsToShift - 1)
            {
                _ptr[i] = rollRight(_ptr[i + wordsToShift + 1],
                                   _ptr[i + wordsToShift], bitsToShift);
            }
        }

        // The last word needs some care, as it must shift in 0's from past the
        // end of the array.
        if (wordsToShift < dim)
        {
            if (bitsToShift == 0)
                _ptr[dim - wordsToShift - 1] = _ptr[dim - 1];
            else
            {
                // Special case: if endBits == 0, then also endMask == 0.
                size_t lastWord = (endBits ? (_ptr[fullWords] & endMask) : _ptr[fullWords - 1]);
                _ptr[dim - wordsToShift - 1] = rollRight(0, lastWord, bitsToShift);
            }
        }

        import stdd.algorithm.comparison : min;
        foreach (i; 0 .. min(wordsToShift, dim))
        {
            _ptr[dim - i - 1] = 0;
        }
    }

    /***************************************
     * Return a string representation of this BitArray.
     *
     * Two format specifiers are supported:
     * $(LI $(B %s) which prints the bits as an array, and)
     * $(LI $(B %b) which prints the bits as 8-bit byte packets)
     * separated with an underscore.
     *
     * Params:
     *     sink = A `char` accepting
     *     $(REF_ALTTEXT output range, isOutputRange, stdd, range, primitives).
     *     fmt = A $(REF FormatSpec, stdd,format) which controls how the data
     *     is displayed.
     */
    void toString(W)(ref W sink, const ref FormatSpec!char fmt) const
    if (isOutputRange!(W, char))
    {
        switch (fmt.spec)
        {
            case 'b':
                return formatBitString(sink);
            case 's':
                return formatBitArray(sink);
            default:
                throw new Exception("Unknown format specifier: %" ~ fmt.spec);
        }
    }

    // @@@DEPRECATED_2.089@@@
    deprecated("To be removed by 2.089. Please use the writer overload instead.")
    void toString(scope void delegate(const(char)[]) sink, const ref FormatSpec!char fmt) const
    {
        switch (fmt.spec)
        {
            case 'b':
                return formatBitString(sink);
            case 's':
                return formatBitArray(sink);
            default:
                throw new Exception("Unknown format specifier: %" ~ fmt.spec);
        }
    }

    /***************************************
     * Return a lazy range of the indices of set bits.
     */
    @property auto bitsSet() const nothrow
    {
        import stdd.algorithm.iteration : filter, map, joiner;
        import stdd.range : iota;

        return iota(dim).
               filter!(i => _ptr[i])().
               map!(i => BitsSet!size_t(_ptr[i], i * bitsPerSizeT))().
               joiner();
    }


    private void formatBitString(Writer)(auto ref Writer sink) const
    {
        if (!length)
            return;

        auto leftover = _len % 8;
        foreach (idx; 0 .. leftover)
        {
            put(sink, cast(char)(this[idx] + '0'));
        }

        if (leftover && _len > 8)
            put(sink, "_");

        size_t count;
        foreach (idx; leftover .. _len)
        {
            put(sink, cast(char)(this[idx] + '0'));
            if (++count == 8 && idx != _len - 1)
            {
                put(sink, "_");
                count = 0;
            }
        }
    }

    private void formatBitArray(Writer)(auto ref Writer sink) const
    {
        put(sink, "[");
        foreach (idx; 0 .. _len)
        {
            put(sink, cast(char)(this[idx] + '0'));
            if (idx + 1 < _len)
                put(sink, ", ");
        }
        put(sink, "]");
    }
}

/// Slicing & bitsSet
/++
    Swaps the endianness of the given integral value or character.
  +/
T swapEndian(T)(T val) @safe pure nothrow @nogc
if (isIntegral!T || isSomeChar!T || isBoolean!T)
{
    static if (val.sizeof == 1)
        return val;
    else static if (isUnsigned!T)
        return swapEndianImpl(val);
    else static if (isIntegral!T)
        return cast(T) swapEndianImpl(cast(Unsigned!T) val);
    else static if (is(Unqual!T == wchar))
        return cast(T) swapEndian(cast(ushort) val);
    else static if (is(Unqual!T == dchar))
        return cast(T) swapEndian(cast(uint) val);
    else
        static assert(0, T.stringof ~ " unsupported by swapEndian.");
}

private ushort swapEndianImpl(ushort val) @safe pure nothrow @nogc
{
    return ((val & 0xff00U) >> 8) |
           ((val & 0x00ffU) << 8);
}

private uint swapEndianImpl(uint val) @trusted pure nothrow @nogc
{
    import core.bitop : bswap;
    return bswap(val);
}

private ulong swapEndianImpl(ulong val) @trusted pure nothrow @nogc
{
    import core.bitop : bswap;
    immutable ulong res = bswap(cast(uint) val);
    return res << 32 | bswap(cast(uint)(val >> 32));
}

private union EndianSwapper(T)
if (canSwapEndianness!T)
{
    Unqual!T value;
    ubyte[T.sizeof] array;

    static if (is(FloatingPointTypeOf!(Unqual!T) == float))
        uint  intValue;
    else static if (is(FloatingPointTypeOf!(Unqual!T) == double))
        ulong intValue;

}


/++
    Converts the given value from the native endianness to big endian and
    returns it as a `ubyte[n]` where `n` is the size of the given type.

    Returning a `ubyte[n]` helps prevent accidentally using a swapped value
    as a regular one (and in the case of floating point values, it's necessary,
    because the FPU will mess up any swapped floating point values. So, you
    can't actually have swapped floating point values as floating point values).

    `real` is not supported, because its size is implementation-dependent
    and therefore could vary from machine to machine (which could make it
    unusable if you tried to transfer it to another machine).
  +/
auto nativeToBigEndian(T)(T val) @safe pure nothrow @nogc
if (canSwapEndianness!T)
{
    return nativeToBigEndianImpl(val);
}

private auto nativeToBigEndianImpl(T)(T val) @safe pure nothrow @nogc
if (isIntegral!T || isSomeChar!T || isBoolean!T)
{
    EndianSwapper!T es = void;

    version(LittleEndian)
        es.value = swapEndian(val);
    else
        es.value = val;

    return es.array;
}

private auto nativeToBigEndianImpl(T)(T val) @safe pure nothrow @nogc
if (isFloatOrDouble!T)
{
    version(LittleEndian)
        return floatEndianImpl!(T, true)(val);
    else
        return floatEndianImpl!(T, false)(val);
}


/++
    Converts the given value from big endian to the native endianness and
    returns it. The value is given as a `ubyte[n]` where `n` is the size
    of the target type. You must give the target type as a template argument,
    because there are multiple types with the same size and so the type of the
    argument is not enough to determine the return type.

    Taking a `ubyte[n]` helps prevent accidentally using a swapped value
    as a regular one (and in the case of floating point values, it's necessary,
    because the FPU will mess up any swapped floating point values. So, you
    can't actually have swapped floating point values as floating point values).
  +/
T bigEndianToNative(T, size_t n)(ubyte[n] val) @safe pure nothrow @nogc
if (canSwapEndianness!T && n == T.sizeof)
{
    return bigEndianToNativeImpl!(T, n)(val);
}

///
private T bigEndianToNativeImpl(T, size_t n)(ubyte[n] val) @safe pure nothrow @nogc
if ((isIntegral!T || isSomeChar!T || isBoolean!T) &&
    n == T.sizeof)
{
    EndianSwapper!T es = void;
    es.array = val;

    version(LittleEndian)
        immutable retval = swapEndian(es.value);
    else
        immutable retval = es.value;

    return retval;
}

private T bigEndianToNativeImpl(T, size_t n)(ubyte[n] val) @safe pure nothrow @nogc
if (isFloatOrDouble!T && n == T.sizeof)
{
    version(LittleEndian)
        return cast(T) floatEndianImpl!(n, true)(val);
    else
        return cast(T) floatEndianImpl!(n, false)(val);
}


/++
    Converts the given value from the native endianness to little endian and
    returns it as a `ubyte[n]` where `n` is the size of the given type.

    Returning a `ubyte[n]` helps prevent accidentally using a swapped value
    as a regular one (and in the case of floating point values, it's necessary,
    because the FPU will mess up any swapped floating point values. So, you
    can't actually have swapped floating point values as floating point values).
  +/
auto nativeToLittleEndian(T)(T val) @safe pure nothrow @nogc
if (canSwapEndianness!T)
{
    return nativeToLittleEndianImpl(val);
}

///
@safe unittest
{
    int i = 12345;
    ubyte[4] swappedI = nativeToLittleEndian(i);
    assert(i == littleEndianToNative!int(swappedI));

    double d = 123.45;
    ubyte[8] swappedD = nativeToLittleEndian(d);
    assert(d == littleEndianToNative!double(swappedD));
}

private auto nativeToLittleEndianImpl(T)(T val) @safe pure nothrow @nogc
if (isIntegral!T || isSomeChar!T || isBoolean!T)
{
    EndianSwapper!T es = void;

    version(BigEndian)
        es.value = swapEndian(val);
    else
        es.value = val;

    return es.array;
}

private auto nativeToLittleEndianImpl(T)(T val) @safe pure nothrow @nogc
if (isFloatOrDouble!T)
{
    version(BigEndian)
        return floatEndianImpl!(T, true)(val);
    else
        return floatEndianImpl!(T, false)(val);
}


/++
    Converts the given value from little endian to the native endianness and
    returns it. The value is given as a `ubyte[n]` where `n` is the size
    of the target type. You must give the target type as a template argument,
    because there are multiple types with the same size and so the type of the
    argument is not enough to determine the return type.

    Taking a `ubyte[n]` helps prevent accidentally using a swapped value
    as a regular one (and in the case of floating point values, it's necessary,
    because the FPU will mess up any swapped floating point values. So, you
    can't actually have swapped floating point values as floating point values).

    `real` is not supported, because its size is implementation-dependent
    and therefore could vary from machine to machine (which could make it
    unusable if you tried to transfer it to another machine).
  +/
T littleEndianToNative(T, size_t n)(ubyte[n] val) @safe pure nothrow @nogc
if (canSwapEndianness!T && n == T.sizeof)
{
    return littleEndianToNativeImpl!T(val);
}

///
@safe unittest
{
    ushort i = 12345;
    ubyte[2] swappedI = nativeToLittleEndian(i);
    assert(i == littleEndianToNative!ushort(swappedI));

    dchar c = 'D';
    ubyte[4] swappedC = nativeToLittleEndian(c);
    assert(c == littleEndianToNative!dchar(swappedC));
}

private T littleEndianToNativeImpl(T, size_t n)(ubyte[n] val) @safe pure nothrow @nogc
if ((isIntegral!T || isSomeChar!T || isBoolean!T) &&
    n == T.sizeof)
{
    EndianSwapper!T es = void;
    es.array = val;

    version(BigEndian)
        immutable retval = swapEndian(es.value);
    else
        immutable retval = es.value;

    return retval;
}

private T littleEndianToNativeImpl(T, size_t n)(ubyte[n] val) @safe pure nothrow @nogc
if (((isFloatOrDouble!T) &&
    n == T.sizeof))
{
    version(BigEndian)
        return floatEndianImpl!(n, true)(val);
    else
        return floatEndianImpl!(n, false)(val);
}

private auto floatEndianImpl(T, bool swap)(T val) @safe pure nothrow @nogc
if (isFloatOrDouble!T)
{
    EndianSwapper!T es = void;
    es.value = val;

    static if (swap)
        es.intValue = swapEndian(es.intValue);

    return es.array;
}

private auto floatEndianImpl(size_t n, bool swap)(ubyte[n] val) @safe pure nothrow @nogc
if (n == 4 || n == 8)
{
    static if (n == 4)       EndianSwapper!float es = void;
    else static if (n == 8)  EndianSwapper!double es = void;

    es.array = val;

    static if (swap)
        es.intValue = swapEndian(es.intValue);

    return es.value;
}

private template isFloatOrDouble(T)
{
    enum isFloatOrDouble = isFloatingPoint!T &&
                           !is(Unqual!(FloatingPointTypeOf!T) == real);
}

@safe unittest
{
    import stdd.meta;
    static foreach (T; AliasSeq!(float, double))
    {
        static assert(isFloatOrDouble!(T));
        static assert(isFloatOrDouble!(const T));
        static assert(isFloatOrDouble!(immutable T));
        static assert(isFloatOrDouble!(shared T));
        static assert(isFloatOrDouble!(shared(const T)));
        static assert(isFloatOrDouble!(shared(immutable T)));
    }

    static assert(!isFloatOrDouble!(real));
    static assert(!isFloatOrDouble!(const real));
    static assert(!isFloatOrDouble!(immutable real));
    static assert(!isFloatOrDouble!(shared real));
    static assert(!isFloatOrDouble!(shared(const real)));
    static assert(!isFloatOrDouble!(shared(immutable real)));
}

private template canSwapEndianness(T)
{
    enum canSwapEndianness = isIntegral!T ||
                             isSomeChar!T ||
                             isBoolean!T ||
                             isFloatOrDouble!T;
}

@safe unittest
{
    import stdd.meta;
    static foreach (T; AliasSeq!(bool, ubyte, byte, ushort, short, uint, int, ulong,
                         long, char, wchar, dchar, float, double))
    {
        static assert(canSwapEndianness!(T));
        static assert(canSwapEndianness!(const T));
        static assert(canSwapEndianness!(immutable T));
        static assert(canSwapEndianness!(shared(T)));
        static assert(canSwapEndianness!(shared(const T)));
        static assert(canSwapEndianness!(shared(immutable T)));
    }

    //!
    static foreach (T; AliasSeq!(real, string, wstring, dstring))
    {
        static assert(!canSwapEndianness!(T));
        static assert(!canSwapEndianness!(const T));
        static assert(!canSwapEndianness!(immutable T));
        static assert(!canSwapEndianness!(shared(T)));
        static assert(!canSwapEndianness!(shared(const T)));
        static assert(!canSwapEndianness!(shared(immutable T)));
    }
}

/++
    Takes a range of `ubyte`s and converts the first `T.sizeof` bytes to
    `T`. The value returned is converted from the given endianness to the
    native endianness. The range is not consumed.

    Params:
        T     = The integral type to convert the first `T.sizeof` bytes to.
        endianness = The endianness that the bytes are assumed to be in.
        range = The range to read from.
        index = The index to start reading from (instead of starting at the
                front). If index is a pointer, then it is updated to the index
                after the bytes read. The overloads with index are only
                available if `hasSlicing!R` is `true`.
  +/

T peek(T, Endian endianness = Endian.bigEndian, R)(R range)
if (canSwapEndianness!T &&
    isForwardRange!R &&
    is(ElementType!R : const ubyte))
{
    static if (hasSlicing!R)
        const ubyte[T.sizeof] bytes = range[0 .. T.sizeof];
    else
    {
        ubyte[T.sizeof] bytes;
        //Make sure that range is not consumed, even if it's a class.
        range = range.save;

        foreach (ref e; bytes)
        {
            e = range.front;
            range.popFront();
        }
    }

    static if (endianness == Endian.bigEndian)
        return bigEndianToNative!T(bytes);
    else
        return littleEndianToNative!T(bytes);
}

/++ Ditto +/
T peek(T, Endian endianness = Endian.bigEndian, R)(R range, size_t index)
if (canSwapEndianness!T &&
    isForwardRange!R &&
    hasSlicing!R &&
    is(ElementType!R : const ubyte))
{
    return peek!(T, endianness)(range, &index);
}

/++ Ditto +/
T peek(T, Endian endianness = Endian.bigEndian, R)(R range, size_t* index)
if (canSwapEndianness!T &&
    isForwardRange!R &&
    hasSlicing!R &&
    is(ElementType!R : const ubyte))
{
    assert(index);

    immutable begin = *index;
    immutable end = begin + T.sizeof;
    const ubyte[T.sizeof] bytes = range[begin .. end];
    *index = end;

    static if (endianness == Endian.bigEndian)
        return bigEndianToNative!T(bytes);
    else
        return littleEndianToNative!T(bytes);
}

///
@system unittest
{
    ubyte[] buffer = [1, 5, 22, 9, 44, 255, 8];
    assert(buffer.peek!uint() == 17110537);
    assert(buffer.peek!ushort() == 261);
    assert(buffer.peek!ubyte() == 1);

    assert(buffer.peek!uint(2) == 369700095);
    assert(buffer.peek!ushort(2) == 5641);
    assert(buffer.peek!ubyte(2) == 22);

    size_t index = 0;
    assert(buffer.peek!ushort(&index) == 261);
    assert(index == 2);

    assert(buffer.peek!uint(&index) == 369700095);
    assert(index == 6);

    assert(buffer.peek!ubyte(&index) == 8);
    assert(index == 7);
}

///
@safe unittest
{
    import stdd.algorithm.iteration : filter;
    ubyte[] buffer = [1, 5, 22, 9, 44, 255, 7];
    auto range = filter!"true"(buffer);
    assert(range.peek!uint() == 17110537);
    assert(range.peek!ushort() == 261);
    assert(range.peek!ubyte() == 1);
}

@system unittest
{
    {
        //bool
        ubyte[] buffer = [0, 1];
        assert(buffer.peek!bool() == false);
        assert(buffer.peek!bool(1) == true);

        size_t index = 0;
        assert(buffer.peek!bool(&index) == false);
        assert(index == 1);

        assert(buffer.peek!bool(&index) == true);
        assert(index == 2);
    }

    {
        //char (8bit)
        ubyte[] buffer = [97, 98, 99, 100];
        assert(buffer.peek!char() == 'a');
        assert(buffer.peek!char(1) == 'b');

        size_t index = 0;
        assert(buffer.peek!char(&index) == 'a');
        assert(index == 1);

        assert(buffer.peek!char(&index) == 'b');
        assert(index == 2);
    }

    {
        //wchar (16bit - 2x ubyte)
        ubyte[] buffer = [1, 5, 32, 29, 1, 7];
        assert(buffer.peek!wchar() == 'ą');
        assert(buffer.peek!wchar(2) == '”');
        assert(buffer.peek!wchar(4) == 'ć');

        size_t index = 0;
        assert(buffer.peek!wchar(&index) == 'ą');
        assert(index == 2);

        assert(buffer.peek!wchar(&index) == '”');
        assert(index == 4);

        assert(buffer.peek!wchar(&index) == 'ć');
        assert(index == 6);
    }

    {
        //dchar (32bit - 4x ubyte)
        ubyte[] buffer = [0, 0, 1, 5, 0, 0, 32, 29, 0, 0, 1, 7];
        assert(buffer.peek!dchar() == 'ą');
        assert(buffer.peek!dchar(4) == '”');
        assert(buffer.peek!dchar(8) == 'ć');

        size_t index = 0;
        assert(buffer.peek!dchar(&index) == 'ą');
        assert(index == 4);

        assert(buffer.peek!dchar(&index) == '”');
        assert(index == 8);

        assert(buffer.peek!dchar(&index) == 'ć');
        assert(index == 12);
    }

    {
        //float (32bit - 4x ubyte)
        ubyte[] buffer = [66, 0, 0, 0, 65, 200, 0, 0];
        assert(buffer.peek!float()== 32.0);
        assert(buffer.peek!float(4) == 25.0f);

        size_t index = 0;
        assert(buffer.peek!float(&index) == 32.0f);
        assert(index == 4);

        assert(buffer.peek!float(&index) == 25.0f);
        assert(index == 8);
    }

    {
        //double (64bit - 8x ubyte)
        ubyte[] buffer = [64, 64, 0, 0, 0, 0, 0, 0, 64, 57, 0, 0, 0, 0, 0, 0];
        assert(buffer.peek!double() == 32.0);
        assert(buffer.peek!double(8) == 25.0);

        size_t index = 0;
        assert(buffer.peek!double(&index) == 32.0);
        assert(index == 8);

        assert(buffer.peek!double(&index) == 25.0);
        assert(index == 16);
    }

    {
        //enum
        ubyte[] buffer = [0, 0, 0, 10, 0, 0, 0, 20, 0, 0, 0, 30];

        enum Foo
        {
            one = 10,
            two = 20,
            three = 30
        }

        assert(buffer.peek!Foo() == Foo.one);
        assert(buffer.peek!Foo(0) == Foo.one);
        assert(buffer.peek!Foo(4) == Foo.two);
        assert(buffer.peek!Foo(8) == Foo.three);

        size_t index = 0;
        assert(buffer.peek!Foo(&index) == Foo.one);
        assert(index == 4);

        assert(buffer.peek!Foo(&index) == Foo.two);
        assert(index == 8);

        assert(buffer.peek!Foo(&index) == Foo.three);
        assert(index == 12);
    }

    {
        //enum - bool
        ubyte[] buffer = [0, 1];

        enum Bool: bool
        {
            bfalse = false,
            btrue = true,
        }

        assert(buffer.peek!Bool() == Bool.bfalse);
        assert(buffer.peek!Bool(0) == Bool.bfalse);
        assert(buffer.peek!Bool(1) == Bool.btrue);

        size_t index = 0;
        assert(buffer.peek!Bool(&index) == Bool.bfalse);
        assert(index == 1);

        assert(buffer.peek!Bool(&index) == Bool.btrue);
        assert(index == 2);
    }

    {
        //enum - float
        ubyte[] buffer = [66, 0, 0, 0, 65, 200, 0, 0];

        enum Float: float
        {
            one = 32.0f,
            two = 25.0f
        }

        assert(buffer.peek!Float() == Float.one);
        assert(buffer.peek!Float(0) == Float.one);
        assert(buffer.peek!Float(4) == Float.two);

        size_t index = 0;
        assert(buffer.peek!Float(&index) == Float.one);
        assert(index == 4);

        assert(buffer.peek!Float(&index) == Float.two);
        assert(index == 8);
    }

    {
        //enum - double
        ubyte[] buffer = [64, 64, 0, 0, 0, 0, 0, 0, 64, 57, 0, 0, 0, 0, 0, 0];

        enum Double: double
        {
            one = 32.0,
            two = 25.0
        }

        assert(buffer.peek!Double() == Double.one);
        assert(buffer.peek!Double(0) == Double.one);
        assert(buffer.peek!Double(8) == Double.two);

        size_t index = 0;
        assert(buffer.peek!Double(&index) == Double.one);
        assert(index == 8);

        assert(buffer.peek!Double(&index) == Double.two);
        assert(index == 16);
    }

    {
        //enum - real
        ubyte[] buffer = [64, 64, 0, 0, 0, 0, 0, 0, 64, 57, 0, 0, 0, 0, 0, 0];

        enum Real: real
        {
            one = 32.0,
            two = 25.0
        }

        static assert(!__traits(compiles, buffer.peek!Real()));
    }
}

/++
    Takes a range of `ubyte`s and converts the first `T.sizeof` bytes to
    `T`. The value returned is converted from the given endianness to the
    native endianness. The `T.sizeof` bytes which are read are consumed from
    the range.

    Params:
        T     = The integral type to convert the first `T.sizeof` bytes to.
        endianness = The endianness that the bytes are assumed to be in.
        range = The range to read from.
  +/
T read(T, Endian endianness = Endian.bigEndian, R)(ref R range)
if (canSwapEndianness!T && isInputRange!R && is(ElementType!R : const ubyte))
{
    static if (hasSlicing!R && is(typeof(R.init[0 .. 0]) : const(ubyte)[]))
    {
        const ubyte[T.sizeof] bytes = range[0 .. T.sizeof];
        range.popFrontN(T.sizeof);
    }
    else
    {
        ubyte[T.sizeof] bytes;

        foreach (ref e; bytes)
        {
            e = range.front;
            range.popFront();
        }
    }

    static if (endianness == Endian.bigEndian)
        return bigEndianToNative!T(bytes);
    else
        return littleEndianToNative!T(bytes);
}

///
@safe unittest
{
    import stdd.range.primitives : empty;
    ubyte[] buffer = [1, 5, 22, 9, 44, 255, 8];
    assert(buffer.length == 7);

    assert(buffer.read!ushort() == 261);
    assert(buffer.length == 5);

    assert(buffer.read!uint() == 369700095);
    assert(buffer.length == 1);

    assert(buffer.read!ubyte() == 8);
    assert(buffer.empty);
}

@safe unittest
{
    {
        //bool
        ubyte[] buffer = [0, 1];
        assert(buffer.length == 2);

        assert(buffer.read!bool() == false);
        assert(buffer.length == 1);

        assert(buffer.read!bool() == true);
        assert(buffer.empty);
    }

    {
        //char (8bit)
        ubyte[] buffer = [97, 98, 99];
        assert(buffer.length == 3);

        assert(buffer.read!char() == 'a');
        assert(buffer.length == 2);

        assert(buffer.read!char() == 'b');
        assert(buffer.length == 1);

        assert(buffer.read!char() == 'c');
        assert(buffer.empty);
    }

    {
        //wchar (16bit - 2x ubyte)
        ubyte[] buffer = [1, 5, 32, 29, 1, 7];
        assert(buffer.length == 6);

        assert(buffer.read!wchar() == 'ą');
        assert(buffer.length == 4);

        assert(buffer.read!wchar() == '”');
        assert(buffer.length == 2);

        assert(buffer.read!wchar() == 'ć');
        assert(buffer.empty);
    }

    {
        //dchar (32bit - 4x ubyte)
        ubyte[] buffer = [0, 0, 1, 5, 0, 0, 32, 29, 0, 0, 1, 7];
        assert(buffer.length == 12);

        assert(buffer.read!dchar() == 'ą');
        assert(buffer.length == 8);

        assert(buffer.read!dchar() == '”');
        assert(buffer.length == 4);

        assert(buffer.read!dchar() == 'ć');
        assert(buffer.empty);
    }

    {
        //float (32bit - 4x ubyte)
        ubyte[] buffer = [66, 0, 0, 0, 65, 200, 0, 0];
        assert(buffer.length == 8);

        assert(buffer.read!float()== 32.0);
        assert(buffer.length == 4);

        assert(buffer.read!float() == 25.0f);
        assert(buffer.empty);
    }

    {
        //double (64bit - 8x ubyte)
        ubyte[] buffer = [64, 64, 0, 0, 0, 0, 0, 0, 64, 57, 0, 0, 0, 0, 0, 0];
        assert(buffer.length == 16);

        assert(buffer.read!double() == 32.0);
        assert(buffer.length == 8);

        assert(buffer.read!double() == 25.0);
        assert(buffer.empty);
    }

    {
        //enum - uint
        ubyte[] buffer = [0, 0, 0, 10, 0, 0, 0, 20, 0, 0, 0, 30];
        assert(buffer.length == 12);

        enum Foo
        {
            one = 10,
            two = 20,
            three = 30
        }

        assert(buffer.read!Foo() == Foo.one);
        assert(buffer.length == 8);

        assert(buffer.read!Foo() == Foo.two);
        assert(buffer.length == 4);

        assert(buffer.read!Foo() == Foo.three);
        assert(buffer.empty);
    }

    {
        //enum - bool
        ubyte[] buffer = [0, 1];
        assert(buffer.length == 2);

        enum Bool: bool
        {
            bfalse = false,
            btrue = true,
        }

        assert(buffer.read!Bool() == Bool.bfalse);
        assert(buffer.length == 1);

        assert(buffer.read!Bool() == Bool.btrue);
        assert(buffer.empty);
    }

    {
        //enum - float
        ubyte[] buffer = [66, 0, 0, 0, 65, 200, 0, 0];
        assert(buffer.length == 8);

        enum Float: float
        {
            one = 32.0f,
            two = 25.0f
        }

        assert(buffer.read!Float() == Float.one);
        assert(buffer.length == 4);

        assert(buffer.read!Float() == Float.two);
        assert(buffer.empty);
    }

    {
        //enum - double
        ubyte[] buffer = [64, 64, 0, 0, 0, 0, 0, 0, 64, 57, 0, 0, 0, 0, 0, 0];
        assert(buffer.length == 16);

        enum Double: double
        {
            one = 32.0,
            two = 25.0
        }

        assert(buffer.read!Double() == Double.one);
        assert(buffer.length == 8);

        assert(buffer.read!Double() == Double.two);
        assert(buffer.empty);
    }

    {
        //enum - real
        ubyte[] buffer = [64, 64, 0, 0, 0, 0, 0, 0, 64, 57, 0, 0, 0, 0, 0, 0];

        enum Real: real
        {
            one = 32.0,
            two = 25.0
        }

        static assert(!__traits(compiles, buffer.read!Real()));
    }
}

// issue 17247
@safe unittest
{
    struct UbyteRange
    {
        ubyte[] impl;
        @property bool empty() { return impl.empty; }
        @property ubyte front() { return impl.front; }
        void popFront() { impl.popFront(); }
        @property UbyteRange save() { return this; }

        // N.B. support slicing but do not return ubyte[] slices.
        UbyteRange opSlice(size_t start, size_t end)
        {
            return UbyteRange(impl[start .. end]);
        }
        @property size_t length() { return impl.length; }
        size_t opDollar() { return impl.length; }
    }
    static assert(hasSlicing!UbyteRange);

    auto r = UbyteRange([0x01, 0x00, 0x00, 0x00]);
    int x = r.read!(int, Endian.littleEndian)();
    assert(x == 1);
}


/++
    Takes an integral value, converts it to the given endianness, and writes it
    to the given range of `ubyte`s as a sequence of `T.sizeof` `ubyte`s
    starting at index. `hasSlicing!R` must be `true`.

    Params:
        T     = The integral type to convert the first `T.sizeof` bytes to.
        endianness = The endianness to _write the bytes in.
        range = The range to _write to.
        value = The value to _write.
        index = The index to start writing to. If index is a pointer, then it
                is updated to the index after the bytes read.
  +/
void write(T, Endian endianness = Endian.bigEndian, R)(R range, T value, size_t index)
if (canSwapEndianness!T &&
    isForwardRange!R &&
    hasSlicing!R &&
    is(ElementType!R : ubyte))
{
    write!(T, endianness)(range, value, &index);
}

/++ Ditto +/
void write(T, Endian endianness = Endian.bigEndian, R)(R range, T value, size_t* index)
if (canSwapEndianness!T &&
    isForwardRange!R &&
    hasSlicing!R &&
    is(ElementType!R : ubyte))
{
    assert(index);

    static if (endianness == Endian.bigEndian)
        immutable bytes = nativeToBigEndian!T(value);
    else
        immutable bytes = nativeToLittleEndian!T(value);

    immutable begin = *index;
    immutable end = begin + T.sizeof;
    *index = end;
    range[begin .. end] = bytes[0 .. T.sizeof];
}

///
@system unittest
{
    ubyte[] buffer = [0, 0, 0, 0, 0, 0, 0, 0];
    buffer.write!uint(29110231u, 0);
    assert(buffer == [1, 188, 47, 215, 0, 0, 0, 0]);

    buffer.write!ushort(927, 0);
    assert(buffer == [3, 159, 47, 215, 0, 0, 0, 0]);

    buffer.write!ubyte(42, 0);
    assert(buffer == [42, 159, 47, 215, 0, 0, 0, 0]);
}

///
@system unittest
{
    ubyte[] buffer = [0, 0, 0, 0, 0, 0, 0, 0, 0];
    buffer.write!uint(142700095u, 2);
    assert(buffer == [0, 0, 8, 129, 110, 63, 0, 0, 0]);

    buffer.write!ushort(19839, 2);
    assert(buffer == [0, 0, 77, 127, 110, 63, 0, 0, 0]);

    buffer.write!ubyte(132, 2);
    assert(buffer == [0, 0, 132, 127, 110, 63, 0, 0, 0]);
}

///
@system unittest
{
    ubyte[] buffer = [0, 0, 0, 0, 0, 0, 0, 0];
    size_t index = 0;
    buffer.write!ushort(261, &index);
    assert(buffer == [1, 5, 0, 0, 0, 0, 0, 0]);
    assert(index == 2);

    buffer.write!uint(369700095u, &index);
    assert(buffer == [1, 5, 22, 9, 44, 255, 0, 0]);
    assert(index == 6);

    buffer.write!ubyte(8, &index);
    assert(buffer == [1, 5, 22, 9, 44, 255, 8, 0]);
    assert(index == 7);
}

/// bool
@system unittest
{
    ubyte[] buffer = [0, 0];
    buffer.write!bool(false, 0);
    assert(buffer == [0, 0]);

    buffer.write!bool(true, 0);
    assert(buffer == [1, 0]);

    buffer.write!bool(true, 1);
    assert(buffer == [1, 1]);

    buffer.write!bool(false, 1);
    assert(buffer == [1, 0]);

    size_t index = 0;
    buffer.write!bool(false, &index);
    assert(buffer == [0, 0]);
    assert(index == 1);

    buffer.write!bool(true, &index);
    assert(buffer == [0, 1]);
    assert(index == 2);
}

/// char(8-bit)
@system unittest
{
    ubyte[] buffer = [0, 0, 0];

    buffer.write!char('a', 0);
    assert(buffer == [97, 0, 0]);

    buffer.write!char('b', 1);
    assert(buffer == [97, 98, 0]);

    size_t index = 0;
    buffer.write!char('a', &index);
    assert(buffer == [97, 98, 0]);
    assert(index == 1);

    buffer.write!char('b', &index);
    assert(buffer == [97, 98, 0]);
    assert(index == 2);

    buffer.write!char('c', &index);
    assert(buffer == [97, 98, 99]);
    assert(index == 3);
}

/// wchar (16bit - 2x ubyte)
@system unittest
{
    ubyte[] buffer = [0, 0, 0, 0];

    buffer.write!wchar('ą', 0);
    assert(buffer == [1, 5, 0, 0]);

    buffer.write!wchar('”', 2);
    assert(buffer == [1, 5, 32, 29]);

    size_t index = 0;
    buffer.write!wchar('ć', &index);
    assert(buffer == [1, 7, 32, 29]);
    assert(index == 2);

    buffer.write!wchar('ą', &index);
    assert(buffer == [1, 7, 1, 5]);
    assert(index == 4);
}

/// dchar (32bit - 4x ubyte)
@system unittest
{
    ubyte[] buffer = [0, 0, 0, 0, 0, 0, 0, 0];

    buffer.write!dchar('ą', 0);
    assert(buffer == [0, 0, 1, 5, 0, 0, 0, 0]);

    buffer.write!dchar('”', 4);
    assert(buffer == [0, 0, 1, 5, 0, 0, 32, 29]);

    size_t index = 0;
    buffer.write!dchar('ć', &index);
    assert(buffer == [0, 0, 1, 7, 0, 0, 32, 29]);
    assert(index == 4);

    buffer.write!dchar('ą', &index);
    assert(buffer == [0, 0, 1, 7, 0, 0, 1, 5]);
    assert(index == 8);
}

/// float (32bit - 4x ubyte)
@system unittest
{
    ubyte[] buffer = [0, 0, 0, 0, 0, 0, 0, 0];

    buffer.write!float(32.0f, 0);
    assert(buffer == [66, 0, 0, 0, 0, 0, 0, 0]);

    buffer.write!float(25.0f, 4);
    assert(buffer == [66, 0, 0, 0, 65, 200, 0, 0]);

    size_t index = 0;
    buffer.write!float(25.0f, &index);
    assert(buffer == [65, 200, 0, 0, 65, 200, 0, 0]);
    assert(index == 4);

    buffer.write!float(32.0f, &index);
    assert(buffer == [65, 200, 0, 0, 66, 0, 0, 0]);
    assert(index == 8);
}

/// double (64bit - 8x ubyte)
@system unittest
{
    ubyte[] buffer = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    buffer.write!double(32.0, 0);
    assert(buffer == [64, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

    buffer.write!double(25.0, 8);
    assert(buffer == [64, 64, 0, 0, 0, 0, 0, 0, 64, 57, 0, 0, 0, 0, 0, 0]);

    size_t index = 0;
    buffer.write!double(25.0, &index);
    assert(buffer == [64, 57, 0, 0, 0, 0, 0, 0, 64, 57, 0, 0, 0, 0, 0, 0]);
    assert(index == 8);

    buffer.write!double(32.0, &index);
    assert(buffer == [64, 57, 0, 0, 0, 0, 0, 0, 64, 64, 0, 0, 0, 0, 0, 0]);
    assert(index == 16);
}

/// enum
@system unittest
{
    ubyte[] buffer = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    enum Foo
    {
        one = 10,
        two = 20,
        three = 30
    }

    buffer.write!Foo(Foo.one, 0);
    assert(buffer == [0, 0, 0, 10, 0, 0, 0, 0, 0, 0, 0, 0]);

    buffer.write!Foo(Foo.two, 4);
    assert(buffer == [0, 0, 0, 10, 0, 0, 0, 20, 0, 0, 0, 0]);

    buffer.write!Foo(Foo.three, 8);
    assert(buffer == [0, 0, 0, 10, 0, 0, 0, 20, 0, 0, 0, 30]);

    size_t index = 0;
    buffer.write!Foo(Foo.three, &index);
    assert(buffer == [0, 0, 0, 30, 0, 0, 0, 20, 0, 0, 0, 30]);
    assert(index == 4);

    buffer.write!Foo(Foo.one, &index);
    assert(buffer == [0, 0, 0, 30, 0, 0, 0, 10, 0, 0, 0, 30]);
    assert(index == 8);

    buffer.write!Foo(Foo.two, &index);
    assert(buffer == [0, 0, 0, 30, 0, 0, 0, 10, 0, 0, 0, 20]);
    assert(index == 12);
}

// enum - bool
@system unittest
{
    ubyte[] buffer = [0, 0];

    enum Bool: bool
    {
        bfalse = false,
        btrue = true,
    }

    buffer.write!Bool(Bool.btrue, 0);
    assert(buffer == [1, 0]);

    buffer.write!Bool(Bool.btrue, 1);
    assert(buffer == [1, 1]);

    size_t index = 0;
    buffer.write!Bool(Bool.bfalse, &index);
    assert(buffer == [0, 1]);
    assert(index == 1);

    buffer.write!Bool(Bool.bfalse, &index);
    assert(buffer == [0, 0]);
    assert(index == 2);
}

/// enum - float
@system unittest
{
    ubyte[] buffer = [0, 0, 0, 0, 0, 0, 0, 0];

    enum Float: float
    {
        one = 32.0f,
        two = 25.0f
    }

    buffer.write!Float(Float.one, 0);
    assert(buffer == [66, 0, 0, 0, 0, 0, 0, 0]);

    buffer.write!Float(Float.two, 4);
    assert(buffer == [66, 0, 0, 0, 65, 200, 0, 0]);

    size_t index = 0;
    buffer.write!Float(Float.two, &index);
    assert(buffer == [65, 200, 0, 0, 65, 200, 0, 0]);
    assert(index == 4);

    buffer.write!Float(Float.one, &index);
    assert(buffer == [65, 200, 0, 0, 66, 0, 0, 0]);
    assert(index == 8);
}

/// enum - double
@system unittest
{
    ubyte[] buffer = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    enum Double: double
    {
        one = 32.0,
        two = 25.0
    }

    buffer.write!Double(Double.one, 0);
    assert(buffer == [64, 64, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]);

    buffer.write!Double(Double.two, 8);
    assert(buffer == [64, 64, 0, 0, 0, 0, 0, 0, 64, 57, 0, 0, 0, 0, 0, 0]);

    size_t index = 0;
    buffer.write!Double(Double.two, &index);
    assert(buffer == [64, 57, 0, 0, 0, 0, 0, 0, 64, 57, 0, 0, 0, 0, 0, 0]);
    assert(index == 8);

    buffer.write!Double(Double.one, &index);
    assert(buffer == [64, 57, 0, 0, 0, 0, 0, 0, 64, 64, 0, 0, 0, 0, 0, 0]);
    assert(index == 16);
}

/// enum - real
@system unittest
{
    ubyte[] buffer = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0];

    enum Real: real
    {
        one = 32.0,
        two = 25.0
    }

    static assert(!__traits(compiles, buffer.write!Real(Real.one)));
}


/++
    Takes an integral value, converts it to the given endianness, and appends
    it to the given range of `ubyte`s (using `put`) as a sequence of
    `T.sizeof` `ubyte`s starting at index. `hasSlicing!R` must be
    `true`.

    Params:
        T     = The integral type to convert the first `T.sizeof` bytes to.
        endianness = The endianness to write the bytes in.
        range = The range to _append to.
        value = The value to _append.
  +/
void append(T, Endian endianness = Endian.bigEndian, R)(R range, T value)
if (canSwapEndianness!T && isOutputRange!(R, ubyte))
{
    static if (endianness == Endian.bigEndian)
        immutable bytes = nativeToBigEndian!T(value);
    else
        immutable bytes = nativeToLittleEndian!T(value);

    put(range, bytes[]);
}

///
@safe unittest
{
    import stdd.array;
    auto buffer = appender!(const ubyte[])();
    buffer.append!ushort(261);
    assert(buffer.data == [1, 5]);

    buffer.append!uint(369700095u);
    assert(buffer.data == [1, 5, 22, 9, 44, 255]);

    buffer.append!ubyte(8);
    assert(buffer.data == [1, 5, 22, 9, 44, 255, 8]);
}

/// bool
@safe unittest
{
    import stdd.array : appender;
    auto buffer = appender!(const ubyte[])();

    buffer.append!bool(true);
    assert(buffer.data == [1]);

    buffer.append!bool(false);
    assert(buffer.data == [1, 0]);
}

/// char wchar dchar
@safe unittest
{
    import stdd.array : appender;
    auto buffer = appender!(const ubyte[])();

    buffer.append!char('a');
    assert(buffer.data == [97]);

    buffer.append!char('b');
    assert(buffer.data == [97, 98]);

    buffer.append!wchar('ą');
    assert(buffer.data == [97, 98, 1, 5]);

    buffer.append!dchar('ą');
        assert(buffer.data == [97, 98, 1, 5, 0, 0, 1, 5]);
}

/// float double
@safe unittest
{
    import stdd.array : appender;
    auto buffer = appender!(const ubyte[])();

    buffer.append!float(32.0f);
    assert(buffer.data == [66, 0, 0, 0]);

    buffer.append!double(32.0);
    assert(buffer.data == [66, 0, 0, 0, 64, 64, 0, 0, 0, 0, 0, 0]);
}

/// enum
@safe unittest
{
    import stdd.array : appender;
    auto buffer = appender!(const ubyte[])();

    enum Foo
    {
        one = 10,
        two = 20,
        three = 30
    }

    buffer.append!Foo(Foo.one);
    assert(buffer.data == [0, 0, 0, 10]);

    buffer.append!Foo(Foo.two);
    assert(buffer.data == [0, 0, 0, 10, 0, 0, 0, 20]);

    buffer.append!Foo(Foo.three);
    assert(buffer.data == [0, 0, 0, 10, 0, 0, 0, 20, 0, 0, 0, 30]);
}

/// enum - bool
@safe unittest
{
    import stdd.array : appender;
    auto buffer = appender!(const ubyte[])();

    enum Bool: bool
    {
        bfalse = false,
        btrue = true,
    }

    buffer.append!Bool(Bool.btrue);
    assert(buffer.data == [1]);

    buffer.append!Bool(Bool.bfalse);
    assert(buffer.data == [1, 0]);

    buffer.append!Bool(Bool.btrue);
    assert(buffer.data == [1, 0, 1]);
}

/// enum - float
@safe unittest
{
    import stdd.array : appender;
    auto buffer = appender!(const ubyte[])();

    enum Float: float
    {
        one = 32.0f,
        two = 25.0f
    }

    buffer.append!Float(Float.one);
    assert(buffer.data == [66, 0, 0, 0]);

    buffer.append!Float(Float.two);
    assert(buffer.data == [66, 0, 0, 0, 65, 200, 0, 0]);
}

/// enum - double
@safe unittest
{
    import stdd.array : appender;
    auto buffer = appender!(const ubyte[])();

    enum Double: double
    {
        one = 32.0,
        two = 25.0
    }

    buffer.append!Double(Double.one);
    assert(buffer.data == [64, 64, 0, 0, 0, 0, 0, 0]);

    buffer.append!Double(Double.two);
    assert(buffer.data == [64, 64, 0, 0, 0, 0, 0, 0, 64, 57, 0, 0, 0, 0, 0, 0]);
}

/// enum - real
@safe unittest
{
    import stdd.array : appender;
    auto buffer = appender!(const ubyte[])();

    enum Real: real
    {
        one = 32.0,
        two = 25.0
    }

    static assert(!__traits(compiles, buffer.append!Real(Real.one)));
}

@system unittest
{
    import stdd.array;
    import stdd.format : format;
    import stdd.meta : AliasSeq;
    static foreach (endianness; [Endian.bigEndian, Endian.littleEndian])
    {{
        auto toWrite = appender!(ubyte[])();
        alias Types = AliasSeq!(uint, int, long, ulong, short, ubyte, ushort, byte, uint);
        ulong[] values = [42, -11, long.max, 1098911981329L, 16, 255, 19012, 2, 17];
        assert(Types.length == values.length);

        size_t index = 0;
        size_t length = 0;
        static foreach (T; Types)
        {
            toWrite.append!(T, endianness)(cast(T) values[index++]);
            length += T.sizeof;
        }

        auto toRead = toWrite.data;
        assert(toRead.length == length);

        index = 0;
        static foreach (T; Types)
        {
            assert(toRead.peek!(T, endianness)() == values[index], format("Failed Index: %s", index));
            assert(toRead.peek!(T, endianness)(0) == values[index], format("Failed Index: %s", index));
            assert(toRead.length == length,
                   format("Failed Index [%s], Actual Length: %s", index, toRead.length));
            assert(toRead.read!(T, endianness)() == values[index], format("Failed Index: %s", index));
            length -= T.sizeof;
            assert(toRead.length == length,
                   format("Failed Index [%s], Actual Length: %s", index, toRead.length));
            ++index;
        }
        assert(toRead.empty);
    }}
}

/**
Counts the number of set bits in the binary representation of `value`.
For signed integers, the sign bit is included in the count.
*/
private uint countBitsSet(T)(T value) @nogc pure nothrow
if (isIntegral!T)
{
    // http://graphics.stanford.edu/~seander/bithacks.html#CountBitsSetParallel
    static if (T.sizeof == 8)
    {
        T c = value - ((value >> 1) & 0x55555555_55555555);
        c = ((c >> 2) & 0x33333333_33333333) + (c & 0x33333333_33333333);
        c = ((c >> 4) + c) & 0x0F0F0F0F_0F0F0F0F;
        c = ((c >> 8) + c) & 0x00FF00FF_00FF00FF;
        c = ((c >> 16) + c) & 0x0000FFFF_0000FFFF;
        c = ((c >> 32) + c) & 0x00000000_FFFFFFFF;
    }
    else static if (T.sizeof == 4)
    {
        T c = value - ((value >> 1) & 0x55555555);
        c = ((c >> 2) & 0x33333333) + (c & 0x33333333);
        c = ((c >> 4) + c) & 0x0F0F0F0F;
        c = ((c >> 8) + c) & 0x00FF00FF;
        c = ((c >> 16) + c) & 0x0000FFFF;
    }
    else static if (T.sizeof == 2)
    {
        uint c = value - ((value >> 1) & 0x5555);
        c = ((c >> 2) & 0x3333) + (c & 0X3333);
        c = ((c >> 4) + c) & 0x0F0F;
        c = ((c >> 8) + c) & 0x00FF;
    }
    else static if (T.sizeof == 1)
    {
        uint c = value - ((value >> 1) & 0x55);
        c = ((c >> 2) & 0x33) + (c & 0X33);
        c = ((c >> 4) + c) & 0x0F;
    }
    else
    {
        static assert(false, "countBitsSet only supports 1, 2, 4, or 8 byte sized integers.");
    }
    return cast(uint) c;
}

@safe unittest
{
    assert(countBitsSet(1) == 1);
    assert(countBitsSet(0) == 0);
    assert(countBitsSet(int.min) == 1);
    assert(countBitsSet(uint.max) == 32);
}

@safe unittest
{
    import stdd.meta;
    static foreach (T; AliasSeq!(byte, ubyte, short, ushort, int, uint, long, ulong))
    {
        assert(countBitsSet(cast(T) 0) == 0);
        assert(countBitsSet(cast(T) 1) == 1);
        assert(countBitsSet(cast(T) 2) == 1);
        assert(countBitsSet(cast(T) 3) == 2);
        assert(countBitsSet(cast(T) 4) == 1);
        assert(countBitsSet(cast(T) 5) == 2);
        assert(countBitsSet(cast(T) 127) == 7);
        static if (isSigned!T)
        {
            assert(countBitsSet(cast(T)-1) == 8 * T.sizeof);
            assert(countBitsSet(T.min) == 1);
        }
        else
        {
            assert(countBitsSet(T.max) == 8 * T.sizeof);
        }
    }
    assert(countBitsSet(1_000_000) == 7);
    foreach (i; 0 .. 63)
        assert(countBitsSet(1UL << i) == 1);
}

private struct BitsSet(T)
{
    static assert(T.sizeof <= 8, "bitsSet assumes T is no more than 64-bit.");

@nogc pure nothrow:

    this(T value, size_t startIndex = 0)
    {
        _value = value;
        // Further calculation is only valid and needed when the range is non-empty.
        if (!_value)
            return;

        import core.bitop : bsf;
        immutable trailingZerosCount = bsf(value);
        _value >>>= trailingZerosCount;
        _index = startIndex + trailingZerosCount;
    }

    @property size_t front()
    {
        return _index;
    }

    @property bool empty() const
    {
        return !_value;
    }

    void popFront()
    {
        assert(_value, "Cannot call popFront on empty range.");

        _value >>>= 1;
        // Further calculation is only valid and needed when the range is non-empty.
        if (!_value)
            return;

        import core.bitop : bsf;
        immutable trailingZerosCount = bsf(_value);
        _value >>>= trailingZerosCount;
        _index += trailingZerosCount + 1;
    }

    @property auto save()
    {
        return this;
    }

    @property size_t length()
    {
        return countBitsSet(_value);
    }

    private T _value;
    private size_t _index;
}

/**
Range that iterates the indices of the set bits in `value`.
Index 0 corresponds to the least significant bit.
For signed integers, the highest index corresponds to the sign bit.
*/
auto bitsSet(T)(T value) @nogc pure nothrow
if (isIntegral!T)
{
    return BitsSet!T(value);
}

+/
