// Written in the D programming language.

/**
This module implements a
$(HTTP erdani.org/publications/cuj-04-2002.html,discriminated union)
type (a.k.a.
$(HTTP en.wikipedia.org/wiki/Tagged_union,tagged union),
$(HTTP en.wikipedia.org/wiki/Algebraic_data_type,algebraic type)).
Such types are useful
for type-uniform binary interfaces, interfacing with scripting
languages, and comfortable exploratory programming.

A $(LREF Variant) object can hold a value of any type, with very few
restrictions (such as `shared` types and noncopyable types). Setting the value
is as immediate as assigning to the `Variant` object. To read back the value of
the appropriate type `T`, use the $(LREF get!T) call. To query whether a
`Variant` currently holds a value of type `T`, use $(LREF peek!T). To fetch the
exact type currently held, call $(LREF type), which returns the `TypeInfo` of
the current value.

In addition to $(LREF Variant), this module also defines the $(LREF Algebraic)
type constructor. Unlike `Variant`, `Algebraic` only allows a finite set of
types, which are specified in the instantiation (e.g. $(D Algebraic!(int,
string)) may only hold an `int` or a `string`).

Credits: Reviewed by Brad Roberts. Daniel Keep provided a detailed code review
prompting the following improvements: (1) better support for arrays; (2) support
for associative arrays; (3) friendlier behavior towards the garbage collector.
Copyright: Copyright Andrei Alexandrescu 2007 - 2015.
License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
Authors:   $(HTTP erdani.org, Andrei Alexandrescu)
Source:    $(PHOBOSSRC stdd/_variant.d)
*/
module stdd.variant;

import stdd.meta, stdd.traits, stdd.typecons;

/++
    Gives the `sizeof` the largest type given.
  +/
template maxSize(T...)
{
    static if (T.length == 1)
    {
        enum size_t maxSize = T[0].sizeof;
    }
    else
    {
        import stdd.algorithm.comparison : max;
        enum size_t maxSize = max(T[0].sizeof, maxSize!(T[1 .. $]));
    }
}
struct This;
private alias This2Variant(V, T...) = AliasSeq!(ReplaceType!(This, V, T));

/**
 * Back-end type seldom used directly by user
 * code. Two commonly-used types using `VariantN` are:
 *
 * $(OL $(LI $(LREF Algebraic): A closed discriminated union with a
 * limited type universe (e.g., $(D Algebraic!(int, double,
 * string)) only accepts these three types and rejects anything
 * else).) $(LI $(LREF Variant): An open discriminated union allowing an
 * unbounded set of types. If any of the types in the `Variant`
 * are larger than the largest built-in type, they will automatically
 * be boxed. This means that even large types will only be the size
 * of a pointer within the `Variant`, but this also implies some
 * overhead. `Variant` can accommodate all primitive types and
 * all user-defined types.))
 *
 * Both `Algebraic` and `Variant` share $(D
 * VariantN)'s interface. (See their respective documentations below.)
 *
 * `VariantN` is a discriminated union type parameterized
 * with the largest size of the types stored (`maxDataSize`)
 * and with the list of allowed types (`AllowedTypes`). If
 * the list is empty, then any type up of size up to $(D
 * maxDataSize) (rounded up for alignment) can be stored in a
 * `VariantN` object without being boxed (types larger
 * than this will be boxed).
 *
 */
struct VariantN(size_t maxDataSize, AllowedTypesParam...)
{
    /**
    The list of allowed types. If empty, any type is allowed.
    */
    alias AllowedTypes = This2Variant!(VariantN, AllowedTypesParam);

private:
    // Compute the largest practical size from maxDataSize
    struct SizeChecker
    {
        int function() fptr;
        ubyte[maxDataSize] data;
    }
    enum size = SizeChecker.sizeof - (int function()).sizeof;

    /** Tells whether a type `T` is statically _allowed for
     * storage inside a `VariantN` object by looking
     * `T` up in `AllowedTypes`.
     */
    public template allowed(T)
    {
        enum bool allowed
            = is(T == VariantN)
            ||
            //T.sizeof <= size &&
            (AllowedTypes.length == 0 || staticIndexOf!(T, AllowedTypes) >= 0);
    }

    // Each internal operation is encoded with an identifier. See
    // the "handler" function below.
    enum OpID { getTypeInfo, get, compare, equals, testConversion, toString,
            index, indexAssign, catAssign, copyOut, length,
            apply, postblit, destruct }

    // state
    ptrdiff_t function(OpID selector, ubyte[size]* store, void* data) fptr
        = &handler!(void);
    union
    {
        ubyte[size] store;
        // conservatively mark the region as pointers
        static if (size >= (void*).sizeof)
            void*[size / (void*).sizeof] p;
    }

    // internals
    // Handler for an uninitialized value
    static ptrdiff_t handler(A : void)(OpID selector, ubyte[size]*, void* parm)
    {
        switch (selector)
        {
        case OpID.getTypeInfo:
            *cast(TypeInfo *) parm = typeid(A);
            break;
        case OpID.copyOut:
            auto target = cast(VariantN *) parm;
            target.fptr = &handler!(A);
            // no need to copy the data (it's garbage)
            break;
        case OpID.compare:
        case OpID.equals:
            auto rhs = cast(const VariantN *) parm;
            return rhs.peek!(A)
                ? 0 // all uninitialized are equal
                : ptrdiff_t.min; // uninitialized variant is not comparable otherwise
        case OpID.toString:
            string * target = cast(string*) parm;
            *target = "<Uninitialized VariantN>";
            break;
        case OpID.postblit:
        case OpID.destruct:
            break;
        case OpID.get:
        case OpID.testConversion:
        case OpID.index:
        case OpID.indexAssign:
        case OpID.catAssign:
        case OpID.length:
            throw new VariantException(
                "Attempt to use an uninitialized VariantN");
        default: assert(false, "Invalid OpID");
        }
        return 0;
    }

    // Handler for all of a type's operations
    static ptrdiff_t handler(A)(OpID selector, ubyte[size]* pStore, void* parm)
    {
        import stdd.conv : to;
        static A* getPtr(void* untyped)
        {
            if (untyped)
            {
                static if (A.sizeof <= size)
                    return cast(A*) untyped;
                else
                    return *cast(A**) untyped;
            }
            return null;
        }

        static ptrdiff_t compare(A* rhsPA, A* zis, OpID selector)
        {
            static if (is(typeof(*rhsPA == *zis)))
            {
                if (*rhsPA == *zis)
                {
                    return 0;
                }
                static if (is(typeof(*zis < *rhsPA)))
                {
                    // Many types (such as any using the default Object opCmp)
                    // will throw on an invalid opCmp, so do it only
                    // if the caller requests it.
                    if (selector == OpID.compare)
                        return *zis < *rhsPA ? -1 : 1;
                    else
                        return ptrdiff_t.min;
                }
                else
                {
                    // Not equal, and type does not support ordering
                    // comparisons.
                    return ptrdiff_t.min;
                }
            }
            else
            {
                // Type does not support comparisons at all.
                return ptrdiff_t.min;
            }
        }

        auto zis = getPtr(pStore);
        // Input: TypeInfo object
        // Output: target points to a copy of *me, if me was not null
        // Returns: true iff the A can be converted to the type represented
        // by the incoming TypeInfo
        static bool tryPutting(A* src, TypeInfo targetType, void* target)
        {
            alias UA = Unqual!A;
            alias MutaTypes = AliasSeq!(UA, ImplicitConversionTargets!UA);
            alias ConstTypes = staticMap!(ConstOf, MutaTypes);
            alias SharedTypes = staticMap!(SharedOf, MutaTypes);
            alias SharedConstTypes = staticMap!(SharedConstOf, MutaTypes);
            alias ImmuTypes  = staticMap!(ImmutableOf, MutaTypes);

            static if (is(A == immutable))
                alias AllTypes = AliasSeq!(ImmuTypes, ConstTypes, SharedConstTypes);
            else static if (is(A == shared))
            {
                static if (is(A == const))
                    alias AllTypes = SharedConstTypes;
                else
                    alias AllTypes = AliasSeq!(SharedTypes, SharedConstTypes);
            }
            else
            {
                static if (is(A == const))
                    alias AllTypes = ConstTypes;
                else
                    alias AllTypes = AliasSeq!(MutaTypes, ConstTypes);
            }

            foreach (T ; AllTypes)
            {
                if (targetType != typeid(T))
                    continue;

                static if (is(typeof(*cast(T*) target = *src)) ||
                           is(T ==        const(U), U) ||
                           is(T ==       shared(U), U) ||
                           is(T == shared const(U), U) ||
                           is(T ==    immutable(U), U))
                {
                    import stdd.conv : emplaceRef;

                    auto zat = cast(T*) target;
                    if (src)
                    {
                        static if (T.sizeof > 0)
                            assert(target, "target must be non-null");

                        emplaceRef(*cast(Unqual!T*) zat, *cast(UA*) src);
                    }
                }
                else
                {
                    // type T is not constructible from A
                    if (src)
                        assert(false, A.stringof);
                }
                return true;
            }
            return false;
        }

        switch (selector)
        {
        case OpID.getTypeInfo:
            *cast(TypeInfo *) parm = typeid(A);
            break;
        case OpID.copyOut:
            auto target = cast(VariantN *) parm;
            assert(target);

            static if (target.size < A.sizeof)
            {
                if (target.type.tsize < A.sizeof)
                {
                    static if (is(A == U[n], U, size_t n))
                    {
                        A* p = cast(A*)(new U[n]).ptr;
                    }
                    else
                    {
                        A* p = new A;
                    }
                    *cast(A**)&target.store = p;
                }
            }
            tryPutting(zis, typeid(A), cast(void*) getPtr(&target.store))
                || assert(false);
            target.fptr = &handler!(A);
            break;
        case OpID.get:
            auto t = * cast(Tuple!(TypeInfo, void*)*) parm;
            return !tryPutting(zis, t[0], t[1]);
        case OpID.testConversion:
            return !tryPutting(null, *cast(TypeInfo*) parm, null);
        case OpID.compare:
        case OpID.equals:
            auto rhsP = cast(VariantN *) parm;
            auto rhsType = rhsP.type;
            // Are we the same?
            if (rhsType == typeid(A))
            {
                // cool! Same type!
                auto rhsPA = getPtr(&rhsP.store);
                return compare(rhsPA, zis, selector);
            }
            else if (rhsType == typeid(void))
            {
                // No support for ordering comparisons with
                // uninitialized vars
                return ptrdiff_t.min;
            }
            VariantN temp;
            // Do I convert to rhs?
            if (tryPutting(zis, rhsType, &temp.store))
            {
                // cool, I do; temp's store contains my data in rhs's type!
                // also fix up its fptr
                temp.fptr = rhsP.fptr;
                // now lhsWithRhsType is a full-blown VariantN of rhs's type
                if (selector == OpID.compare)
                    return temp.opCmp(*rhsP);
                else
                    return temp.opEquals(*rhsP) ? 0 : 1;
            }
            // Does rhs convert to zis?
            auto t = tuple(typeid(A), &temp.store);
            if (rhsP.fptr(OpID.get, &rhsP.store, &t) == 0)
            {
                // cool! Now temp has rhs in my type!
                auto rhsPA = getPtr(&temp.store);
                return compare(rhsPA, zis, selector);
            }
            return ptrdiff_t.min; // dunno
        case OpID.toString:
            auto target = cast(string*) parm;
            static if (is(typeof(to!(string)(*zis))))
            {
                *target = to!(string)(*zis);
                break;
            }
            // TODO: The following test evaluates to true for shared objects.
            //       Use __traits for now until this is sorted out.
            // else static if (is(typeof((*zis).toString)))
            else static if (__traits(compiles, {(*zis).toString();}))
            {
                *target = (*zis).toString();
                break;
            }
            else
            {
                throw new VariantException(typeid(A), typeid(string));
            }

        case OpID.index:
            auto result = cast(Variant*) parm;
            static if (isArray!(A) && !is(Unqual!(typeof(A.init[0])) == void))
            {
                // array type; input and output are the same VariantN
                size_t index = result.convertsTo!(int)
                    ? result.get!(int) : result.get!(size_t);
                *result = (*zis)[index];
                break;
            }
            else static if (isAssociativeArray!(A))
            {
                *result = (*zis)[result.get!(typeof(A.init.keys[0]))];
                break;
            }
            else
            {
                throw new VariantException(typeid(A), result[0].type);
            }

        case OpID.indexAssign:
            // array type; result comes first, index comes second
            auto args = cast(Variant*) parm;
            static if (isArray!(A) && is(typeof((*zis)[0] = (*zis)[0])))
            {
                size_t index = args[1].convertsTo!(int)
                    ? args[1].get!(int) : args[1].get!(size_t);
                (*zis)[index] = args[0].get!(typeof((*zis)[0]));
                break;
            }
            else static if (isAssociativeArray!(A))
            {
                (*zis)[args[1].get!(typeof(A.init.keys[0]))]
                    = args[0].get!(typeof(A.init.values[0]));
                break;
            }
            else
            {
                throw new VariantException(typeid(A), args[0].type);
            }

        case OpID.catAssign:
            static if (!is(Unqual!(typeof((*zis)[0])) == void) && is(typeof((*zis)[0])) && is(typeof((*zis) ~= *zis)))
            {
                // array type; parm is the element to append
                auto arg = cast(Variant*) parm;
                alias E = typeof((*zis)[0]);
                if (arg[0].convertsTo!(E))
                {
                    // append one element to the array
                    (*zis) ~= [ arg[0].get!(E) ];
                }
                else
                {
                    // append a whole array to the array
                    (*zis) ~= arg[0].get!(A);
                }
                break;
            }
            else
            {
                throw new VariantException(typeid(A), typeid(void[]));
            }

        case OpID.length:
            static if (isArray!(A) || isAssociativeArray!(A))
            {
                return zis.length;
            }
            else
            {
                throw new VariantException(typeid(A), typeid(void[]));
            }

        case OpID.apply:
            static if (!isFunctionPointer!A && !isDelegate!A)
            {
                import stdd.conv : text;
                import stdd.exception : enforce;
                enforce(0, text("Cannot apply `()' to a value of type `",
                                A.stringof, "'."));
            }
            else
            {
                import stdd.conv : text;
                import stdd.exception : enforce;
                alias ParamTypes = Parameters!A;
                auto p = cast(Variant*) parm;
                auto argCount = p.get!size_t;
                // To assign the tuple we need to use the unqualified version,
                // otherwise we run into issues such as with const values.
                // We still get the actual type from the Variant though
                // to ensure that we retain const correctness.
                Tuple!(staticMap!(Unqual, ParamTypes)) t;
                enforce(t.length == argCount,
                        text("Argument count mismatch: ",
                             A.stringof, " expects ", t.length,
                             " argument(s), not ", argCount, "."));
                auto variantArgs = p[1 .. argCount + 1];
                foreach (i, T; ParamTypes)
                {
                    t[i] = cast() variantArgs[i].get!T;
                }

                auto args = cast(Tuple!(ParamTypes))t;
                static if (is(ReturnType!A == void))
                {
                    (*zis)(args.expand);
                    *p = Variant.init; // void returns uninitialized Variant.
                }
                else
                {
                    *p = (*zis)(args.expand);
                }
            }
            break;

        case OpID.postblit:
            static if (hasElaborateCopyConstructor!A)
            {
                zis.__xpostblit();
            }
            break;

        case OpID.destruct:
            static if (hasElaborateDestructor!A)
            {
                zis.__xdtor();
            }
            break;

        default: assert(false);
        }
        return 0;
    }

public:
    /** Constructs a `VariantN` value given an argument of a
     * generic type. Statically rejects disallowed types.
     */

    this(T)(T value)
    {
        static assert(allowed!(T), "Cannot store a " ~ T.stringof
            ~ " in a " ~ VariantN.stringof);
        opAssign(value);
    }

    /// Allows assignment from a subset algebraic type
    this(T : VariantN!(tsize, Types), size_t tsize, Types...)(T value)
        if (!is(T : VariantN) && Types.length > 0 && allSatisfy!(allowed, Types))
    {
        opAssign(value);
    }

    static if (!AllowedTypes.length || anySatisfy!(hasElaborateCopyConstructor, AllowedTypes))
    {
        this(this)
        {
            fptr(OpID.postblit, &store, null);
        }
    }

    static if (!AllowedTypes.length || anySatisfy!(hasElaborateDestructor, AllowedTypes))
    {
        ~this()
        {
            // Infer the safety of the provided types
            static if (AllowedTypes.length)
            {
                if (0)
                {
                    AllowedTypes var;
                }
            }
            (() @trusted => fptr(OpID.destruct, &store, null))();
        }
    }

    /** Assigns a `VariantN` from a generic
     * argument. Statically rejects disallowed types. */

    VariantN opAssign(T)(T rhs)
    {
        //writeln(typeid(rhs));
        static assert(allowed!(T), "Cannot store a " ~ T.stringof
            ~ " in a " ~ VariantN.stringof ~ ". Valid types are "
                ~ AllowedTypes.stringof);

        static if (is(T : VariantN))
        {
            rhs.fptr(OpID.copyOut, &rhs.store, &this);
        }
        else static if (is(T : const(VariantN)))
        {
            static assert(false,
                    "Assigning Variant objects from const Variant"~
                    " objects is currently not supported.");
        }
        else
        {
            static if (!AllowedTypes.length || anySatisfy!(hasElaborateDestructor, AllowedTypes))
            {
                // Assignment should destruct previous value
                fptr(OpID.destruct, &store, null);
            }

            static if (T.sizeof <= size)
            {
                import core.stddc.string : memcpy;
                // rhs has already been copied onto the stack, so even if T is
                // shared, it's not really shared. Therefore, we can safely
                // remove the shared qualifier when copying, as we are only
                // copying from the unshared stack.
                //
                // In addition, the storage location is not accessible outside
                // the Variant, so even if shared data is stored there, it's
                // not really shared, as it's copied out as well.
                memcpy(&store, cast(const(void*)) &rhs, rhs.sizeof);
                static if (hasElaborateCopyConstructor!T)
                {
                    // Safer than using typeid's postblit function because it
                    // type-checks the postblit function against the qualifiers
                    // of the type.
                    (cast(T*)&store).__xpostblit();
                }
            }
            else
            {
                import core.stddc.string : memcpy;
                static if (__traits(compiles, {new T(T.init);}))
                {
                    auto p = new T(rhs);
                }
                else static if (is(T == U[n], U, size_t n))
                {
                    auto p = cast(T*)(new U[n]).ptr;
                    *p = rhs;
                }
                else
                {
                    auto p = new T;
                    *p = rhs;
                }
                memcpy(&store, &p, p.sizeof);
            }
            fptr = &handler!(T);
        }
        return this;
    }

    // Allow assignment from another variant which is a subset of this one
    VariantN opAssign(T : VariantN!(tsize, Types), size_t tsize, Types...)(T rhs)
        if (!is(T : VariantN) && Types.length > 0 && allSatisfy!(allowed, Types))
    {
        // discover which type rhs is actually storing
        foreach (V; T.AllowedTypes)
            if (rhs.type == typeid(V))
                return this = rhs.get!V;
        assert(0, T.AllowedTypes.stringof);
    }


    Variant opCall(P...)(auto ref P params)
    {
        Variant[P.length + 1] pack;
        pack[0] = P.length;
        foreach (i, _; params)
        {
            pack[i + 1] = params[i];
        }
        fptr(OpID.apply, &store, &pack);
        return pack[0];
    }

    /** Returns true if and only if the `VariantN` object
     * holds a valid value (has been initialized with, or assigned
     * from, a valid value).
     */
    @property bool hasValue() const pure nothrow
    {
        // @@@BUG@@@ in compiler, the cast shouldn't be needed
        return cast(typeof(&handler!(void))) fptr != &handler!(void);
    }

    /**
     * If the `VariantN` object holds a value of the
     * $(I exact) type `T`, returns a pointer to that
     * value. Otherwise, returns `null`. In cases
     * where `T` is statically disallowed, $(D
     * peek) will not compile.
     */
    @property inout(T)* peek(T)() inout
    {
        static if (!is(T == void))
            static assert(allowed!(T), "Cannot store a " ~ T.stringof
                    ~ " in a " ~ VariantN.stringof);
        if (type != typeid(T))
            return null;
        static if (T.sizeof <= size)
            return cast(inout T*)&store;
        else
            return *cast(inout T**)&store;
    }

    /**
     * Returns the `typeid` of the currently held value.
     */
    @property TypeInfo type() const nothrow @trusted
    {
        scope(failure) assert(0);

        TypeInfo result;
        fptr(OpID.getTypeInfo, null, &result);
        return result;
    }

    /**
     * Returns `true` if and only if the `VariantN`
     * object holds an object implicitly convertible to type `T`.
     * Implicit convertibility is defined as per
     * $(REF_ALTTEXT ImplicitConversionTargets, ImplicitConversionTargets, stdd,traits).
     */
    @property bool convertsTo(T)() const
    {
        TypeInfo info = typeid(T);
        return fptr(OpID.testConversion, null, &info) == 0;
    }

    /**
    Returns the value stored in the `VariantN` object, either by specifying the
    needed type or the index in the list of allowed types. The latter overload
    only applies to bounded variants (e.g. $(LREF Algebraic)).

    Params:
    T = The requested type. The currently stored value must implicitly convert
    to the requested type, in fact `DecayStaticToDynamicArray!T`. If an
    implicit conversion is not possible, throws a `VariantException`.
    index = The index of the type among `AllowedTypesParam`, zero-based.
     */
    @property inout(T) get(T)() inout
    {
        inout(T) result = void;
        static if (is(T == shared))
            alias R = shared Unqual!T;
        else
            alias R = Unqual!T;
        auto buf = tuple(typeid(T), cast(R*)&result);

        if (fptr(OpID.get, cast(ubyte[size]*) &store, &buf))
        {
            throw new VariantException(type, typeid(T));
        }
        return result;
    }

    /// Ditto
    @property auto get(uint index)() inout
    if (index < AllowedTypes.length)
    {
        foreach (i, T; AllowedTypes)
        {
            static if (index == i) return get!T;
        }
        assert(0);
    }

    /**
     * Returns the value stored in the `VariantN` object,
     * explicitly converted (coerced) to the requested type $(D
     * T). If `T` is a string type, the value is formatted as
     * a string. If the `VariantN` object is a string, a
     * parse of the string to type `T` is attempted. If a
     * conversion is not possible, throws a $(D
     * VariantException).
     */

    @property T coerce(T)()
    {
        import stdd.conv : to, text;
        static if (isNumeric!T || isBoolean!T)
        {
            if (convertsTo!real)
            {
                // maybe optimize this fella; handle ints separately
                return to!T(get!real);
            }
            else if (convertsTo!(const(char)[]))
            {
                return to!T(get!(const(char)[]));
            }
            // I'm not sure why this doesn't convert to const(char),
            // but apparently it doesn't (probably a deeper bug).
            //
            // Until that is fixed, this quick addition keeps a common
            // function working. "10".coerce!int ought to work.
            else if (convertsTo!(immutable(char)[]))
            {
                return to!T(get!(immutable(char)[]));
            }
            else
            {
                import stdd.exception : enforce;
                enforce(false, text("Type ", type, " does not convert to ",
                                typeid(T)));
                assert(0);
            }
        }
        else static if (is(T : Object))
        {
            return to!(T)(get!(Object));
        }
        else static if (isSomeString!(T))
        {
            return to!(T)(toString());
        }
        else
        {
            // Fix for bug 1649
            static assert(false, "unsupported type for coercion");
        }
    }

    /**
     * Formats the stored value as a string.
     */

    string toString()
    {
        string result;
        fptr(OpID.toString, &store, &result) == 0 || assert(false);
        return result;
    }

    /**
     * Comparison for equality used by the "==" and "!="  operators.
     */

    // returns 1 if the two are equal
    bool opEquals(T)(auto ref T rhs) const
    if (allowed!T || is(Unqual!T == VariantN))
    {
        static if (is(Unqual!T == VariantN))
            alias temp = rhs;
        else
            auto temp = VariantN(rhs);
        return !fptr(OpID.equals, cast(ubyte[size]*) &store,
                     cast(void*) &temp);
    }

    // workaround for bug 10567 fix
    int opCmp(ref const VariantN rhs) const
    {
        return (cast() this).opCmp!(VariantN)(cast() rhs);
    }

    /**
     * Ordering comparison used by the "<", "<=", ">", and ">="
     * operators. In case comparison is not sensible between the held
     * value and `rhs`, an exception is thrown.
     */

    int opCmp(T)(T rhs)
    if (allowed!T)  // includes T == VariantN
    {
        static if (is(T == VariantN))
            alias temp = rhs;
        else
            auto temp = VariantN(rhs);
        auto result = fptr(OpID.compare, &store, &temp);
        if (result == ptrdiff_t.min)
        {
            throw new VariantException(type, temp.type);
        }

        assert(result >= -1 && result <= 1);  // Should be true for opCmp.
        return cast(int) result;
    }

    /**
     * Computes the hash of the held value.
     */

    size_t toHash() const nothrow @safe
    {
        return type.getHash(&store);
    }

    private VariantN opArithmetic(T, string op)(T other)
    {
        static if (isInstanceOf!(.VariantN, T))
        {
            string tryUseType(string tp)
            {
                import stdd.format : format;
                return q{
                    static if (allowed!%1$s && T.allowed!%1$s)
                        if (convertsTo!%1$s && other.convertsTo!%1$s)
                            return VariantN(get!%1$s %2$s other.get!%1$s);
                }.format(tp, op);
            }

            mixin(tryUseType("uint"));
            mixin(tryUseType("int"));
            mixin(tryUseType("ulong"));
            mixin(tryUseType("long"));
            mixin(tryUseType("float"));
            mixin(tryUseType("double"));
            mixin(tryUseType("real"));
        }
        else
        {
            static if (allowed!T)
                if (auto pv = peek!T) return VariantN(mixin("*pv " ~ op ~ " other"));
            static if (allowed!uint && is(typeof(T.max) : uint) && isUnsigned!T)
                if (convertsTo!uint) return VariantN(mixin("get!(uint) " ~ op ~ " other"));
            static if (allowed!int && is(typeof(T.max) : int) && !isUnsigned!T)
                if (convertsTo!int) return VariantN(mixin("get!(int) " ~ op ~ " other"));
            static if (allowed!ulong && is(typeof(T.max) : ulong) && isUnsigned!T)
                if (convertsTo!ulong) return VariantN(mixin("get!(ulong) " ~ op ~ " other"));
            static if (allowed!long && is(typeof(T.max) : long) && !isUnsigned!T)
                if (convertsTo!long) return VariantN(mixin("get!(long) " ~ op ~ " other"));
            static if (allowed!float && is(T : float))
                if (convertsTo!float) return VariantN(mixin("get!(float) " ~ op ~ " other"));
            static if (allowed!double && is(T : double))
                if (convertsTo!double) return VariantN(mixin("get!(double) " ~ op ~ " other"));
            static if (allowed!real && is (T : real))
                if (convertsTo!real) return VariantN(mixin("get!(real) " ~ op ~ " other"));
        }

        throw new VariantException("No possible match found for VariantN "~op~" "~T.stringof);
    }

    private VariantN opLogic(T, string op)(T other)
    {
        VariantN result;
        static if (is(T == VariantN))
        {
            if (convertsTo!(uint) && other.convertsTo!(uint))
                result = mixin("get!(uint) " ~ op ~ " other.get!(uint)");
            else if (convertsTo!(int) && other.convertsTo!(int))
                result = mixin("get!(int) " ~ op ~ " other.get!(int)");
            else if (convertsTo!(ulong) && other.convertsTo!(ulong))
                result = mixin("get!(ulong) " ~ op ~ " other.get!(ulong)");
            else
                result = mixin("get!(long) " ~ op ~ " other.get!(long)");
        }
        else
        {
            if (is(typeof(T.max) : uint) && T.min == 0 && convertsTo!(uint))
                result = mixin("get!(uint) " ~ op ~ " other");
            else if (is(typeof(T.max) : int) && T.min < 0 && convertsTo!(int))
                result = mixin("get!(int) " ~ op ~ " other");
            else if (is(typeof(T.max) : ulong) && T.min == 0
                     && convertsTo!(ulong))
                result = mixin("get!(ulong) " ~ op ~ " other");
            else
                result = mixin("get!(long) " ~ op ~ " other");
        }
        return result;
    }

    /**
     * Arithmetic between `VariantN` objects and numeric
     * values. All arithmetic operations return a `VariantN`
     * object typed depending on the types of both values
     * involved. The conversion rules mimic D's built-in rules for
     * arithmetic conversions.
     */

    // Adapted from http://www.prowiki.org/wiki4d/wiki.cgi?DanielKeep/Variant
    // arithmetic
    VariantN opAdd(T)(T rhs) { return opArithmetic!(T, "+")(rhs); }
    ///ditto
    VariantN opSub(T)(T rhs) { return opArithmetic!(T, "-")(rhs); }

    // Commenteed all _r versions for now because of ambiguities
    // arising when two Variants are used

    // ///ditto
    // VariantN opSub_r(T)(T lhs)
    // {
    //     return VariantN(lhs).opArithmetic!(VariantN, "-")(this);
    // }
    ///ditto
    VariantN opMul(T)(T rhs) { return opArithmetic!(T, "*")(rhs); }
    ///ditto
    VariantN opDiv(T)(T rhs) { return opArithmetic!(T, "/")(rhs); }
    // ///ditto
    // VariantN opDiv_r(T)(T lhs)
    // {
    //     return VariantN(lhs).opArithmetic!(VariantN, "/")(this);
    // }
    ///ditto
    VariantN opMod(T)(T rhs) { return opArithmetic!(T, "%")(rhs); }
    // ///ditto
    // VariantN opMod_r(T)(T lhs)
    // {
    //     return VariantN(lhs).opArithmetic!(VariantN, "%")(this);
    // }
    ///ditto
    VariantN opAnd(T)(T rhs) { return opLogic!(T, "&")(rhs); }
    ///ditto
    VariantN opOr(T)(T rhs) { return opLogic!(T, "|")(rhs); }
    ///ditto
    VariantN opXor(T)(T rhs) { return opLogic!(T, "^")(rhs); }
    ///ditto
    VariantN opShl(T)(T rhs) { return opLogic!(T, "<<")(rhs); }
    // ///ditto
    // VariantN opShl_r(T)(T lhs)
    // {
    //     return VariantN(lhs).opLogic!(VariantN, "<<")(this);
    // }
    ///ditto
    VariantN opShr(T)(T rhs) { return opLogic!(T, ">>")(rhs); }
    // ///ditto
    // VariantN opShr_r(T)(T lhs)
    // {
    //     return VariantN(lhs).opLogic!(VariantN, ">>")(this);
    // }
    ///ditto
    VariantN opUShr(T)(T rhs) { return opLogic!(T, ">>>")(rhs); }
    // ///ditto
    // VariantN opUShr_r(T)(T lhs)
    // {
    //     return VariantN(lhs).opLogic!(VariantN, ">>>")(this);
    // }
    ///ditto
    VariantN opCat(T)(T rhs)
    {
        auto temp = this;
        temp ~= rhs;
        return temp;
    }
    // ///ditto
    // VariantN opCat_r(T)(T rhs)
    // {
    //     VariantN temp = rhs;
    //     temp ~= this;
    //     return temp;
    // }

    ///ditto
    VariantN opAddAssign(T)(T rhs)  { return this = this + rhs; }
    ///ditto
    VariantN opSubAssign(T)(T rhs)  { return this = this - rhs; }
    ///ditto
    VariantN opMulAssign(T)(T rhs)  { return this = this * rhs; }
    ///ditto
    VariantN opDivAssign(T)(T rhs)  { return this = this / rhs; }
    ///ditto
    VariantN opModAssign(T)(T rhs)  { return this = this % rhs; }
    ///ditto
    VariantN opAndAssign(T)(T rhs)  { return this = this & rhs; }
    ///ditto
    VariantN opOrAssign(T)(T rhs)   { return this = this | rhs; }
    ///ditto
    VariantN opXorAssign(T)(T rhs)  { return this = this ^ rhs; }
    ///ditto
    VariantN opShlAssign(T)(T rhs)  { return this = this << rhs; }
    ///ditto
    VariantN opShrAssign(T)(T rhs)  { return this = this >> rhs; }
    ///ditto
    VariantN opUShrAssign(T)(T rhs) { return this = this >>> rhs; }
    ///ditto
    VariantN opCatAssign(T)(T rhs)
    {
        auto toAppend = Variant(rhs);
        fptr(OpID.catAssign, &store, &toAppend) == 0 || assert(false);
        return this;
    }

    /**
     * Array and associative array operations. If a $(D
     * VariantN) contains an (associative) array, it can be indexed
     * into. Otherwise, an exception is thrown.
     */
    inout(Variant) opIndex(K)(K i) inout
    {
        auto result = Variant(i);
        fptr(OpID.index, cast(ubyte[size]*) &store, &result) == 0 || assert(false);
        return result;
    }

    /// ditto
    Variant opIndexAssign(T, N)(T value, N i)
    {
        static if (AllowedTypes.length && !isInstanceOf!(.VariantN, T))
        {
            enum canAssign(U) = __traits(compiles, (U u){ u[i] = value; });
            static assert(anySatisfy!(canAssign, AllowedTypes),
                "Cannot assign " ~ T.stringof ~ " to " ~ VariantN.stringof ~
                " indexed with " ~ N.stringof);
        }
        Variant[2] args = [ Variant(value), Variant(i) ];
        fptr(OpID.indexAssign, &store, &args) == 0 || assert(false);
        return args[0];
    }

    /// ditto
    Variant opIndexOpAssign(string op, T, N)(T value, N i)
    {
        return opIndexAssign(mixin(`opIndex(i)` ~ op ~ `value`), i);
    }

    /** If the `VariantN` contains an (associative) array,
     * returns the _length of that array. Otherwise, throws an
     * exception.
     */
    @property size_t length()
    {
        return cast(size_t) fptr(OpID.length, &store, null);
    }

    /**
       If the `VariantN` contains an array, applies `dg` to each
       element of the array in turn. Otherwise, throws an exception.
     */
    int opApply(Delegate)(scope Delegate dg) if (is(Delegate == delegate))
    {
        alias A = Parameters!(Delegate)[0];
        if (type == typeid(A[]))
        {
            auto arr = get!(A[]);
            foreach (ref e; arr)
            {
                if (dg(e)) return 1;
            }
        }
        else static if (is(A == VariantN))
        {
            foreach (i; 0 .. length)
            {
                // @@@TODO@@@: find a better way to not confuse
                // clients who think they change values stored in the
                // Variant when in fact they are only changing tmp.
                auto tmp = this[i];
                debug scope(exit) assert(tmp == this[i]);
                if (dg(tmp)) return 1;
            }
        }
        else
        {
            import stdd.conv : text;
            import stdd.exception : enforce;
            enforce(false, text("Variant type ", type,
                            " not iterable with values of type ",
                            A.stringof));
        }
        return 0;
    }
}

/**
_Algebraic data type restricted to a closed set of possible
types. It's an alias for $(LREF VariantN) with an
appropriately-constructed maximum size. `Algebraic` is
useful when it is desirable to restrict what a discriminated type
could hold to the end of defining simpler and more efficient
manipulation.

*/
template Algebraic(T...)
{
    alias Algebraic = VariantN!(maxSize!T, T);
}

private struct FakeComplexReal
{
    real re, im;
}

/**
Alias for $(LREF VariantN) instantiated with the largest size of `creal`,
`char[]`, and `void delegate()`. This ensures that `Variant` is large enough
to hold all of D's predefined types unboxed, including all numeric types,
pointers, delegates, and class references.  You may want to use
`VariantN` directly with a different maximum size either for
storing larger types unboxed, or for saving memory.
 */
alias Variant = VariantN!(maxSize!(FakeComplexReal, char[], void delegate()));

/**
 * Returns an array of variants constructed from `args`.
 *
 * This is by design. During construction the `Variant` needs
 * static type information about the type being held, so as to store a
 * pointer to function for fast retrieval.
 */
Variant[] variantArray(T...)(T args)
{
    Variant[] result;
    foreach (arg; args)
    {
        result ~= Variant(arg);
    }
    return result;
}

/**
 * Thrown in three cases:
 *
 * $(OL $(LI An uninitialized `Variant` is used in any way except
 * assignment and `hasValue`;) $(LI A `get` or
 * `coerce` is attempted with an incompatible target type;)
 * $(LI A comparison between `Variant` objects of
 * incompatible types is attempted.))
 *
 */

// @@@ BUG IN COMPILER. THE 'STATIC' BELOW SHOULD NOT COMPILE
static class VariantException : Exception
{
    /// The source type in the conversion or comparison
    TypeInfo source;
    /// The target type in the conversion or comparison
    TypeInfo target;
    this(string s)
    {
        super(s);
    }
    this(TypeInfo source, TypeInfo target)
    {
        super("Variant: attempting to use incompatible types "
                            ~ source.toString()
                            ~ " and " ~ target.toString());
        this.source = source;
        this.target = target;
    }
}


/**
 * Applies a delegate or function to the given $(LREF Algebraic) depending on the held type,
 * ensuring that all types are handled by the visiting functions.
 *
 * The delegate or function having the currently held value as parameter is called
 * with `variant`'s current value. Visiting handlers are passed
 * in the template parameter list.
 * It is statically ensured that all held types of
 * `variant` are handled across all handlers.
 * `visit` allows delegates and static functions to be passed
 * as parameters.
 *
 * If a function with an untyped parameter is specified, this function is called
 * when the variant contains a type that does not match any other function.
 * This can be used to apply the same function across multiple possible types.
 * Exactly one generic function is allowed.
 *
 * If a function without parameters is specified, this function is called
 * when `variant` doesn't hold a value. Exactly one parameter-less function
 * is allowed.
 *
 * Duplicate overloads matching the same type in one of the visitors are disallowed.
 *
 * Returns: The return type of visit is deduced from the visiting functions and must be
 * the same across all overloads.
 * Throws: $(LREF VariantException) if `variant` doesn't hold a value and no
 * parameter-less fallback function is specified.
 */
template visit(Handlers...)
if (Handlers.length > 0)
{
    ///
    auto visit(VariantType)(VariantType variant)
        if (isAlgebraic!VariantType)
    {
        return visitImpl!(true, VariantType, Handlers)(variant);
    }
}
/**
 * Behaves as $(LREF visit) but doesn't enforce that all types are handled
 * by the visiting functions.
 *
 * If a parameter-less function is specified it is called when
 * either `variant` doesn't hold a value or holds a type
 * which isn't handled by the visiting functions.
 *
 * Returns: The return type of tryVisit is deduced from the visiting functions and must be
 * the same across all overloads.
 * Throws: $(LREF VariantException) if `variant` doesn't hold a value or
 * `variant` holds a value which isn't handled by the visiting functions,
 * when no parameter-less fallback function is specified.
 */
template tryVisit(Handlers...)
if (Handlers.length > 0)
{
    ///
    auto tryVisit(VariantType)(VariantType variant)
        if (isAlgebraic!VariantType)
    {
        return visitImpl!(false, VariantType, Handlers)(variant);
    }
}


private template isAlgebraic(Type)
{
    static if (is(Type _ == VariantN!T, T...))
        enum isAlgebraic = T.length >= 2; // T[0] == maxDataSize, T[1..$] == AllowedTypesParam
    else
        enum isAlgebraic = false;
}

private auto visitImpl(bool Strict, VariantType, Handler...)(VariantType variant)
if (isAlgebraic!VariantType && Handler.length > 0)
{
    alias AllowedTypes = VariantType.AllowedTypes;


    /**
     * Returns: Struct where `indices`  is an array which
     * contains at the n-th position the index in Handler which takes the
     * n-th type of AllowedTypes. If an Handler doesn't match an
     * AllowedType, -1 is set. If a function in the delegates doesn't
     * have parameters, the field `exceptionFuncIdx` is set;
     * otherwise it's -1.
     */
    auto visitGetOverloadMap()
    {
        struct Result {
            int[AllowedTypes.length] indices;
            int exceptionFuncIdx = -1;
            int generalFuncIdx = -1;
        }

        Result result;

        foreach (tidx, T; AllowedTypes)
        {
            bool added = false;
            foreach (dgidx, dg; Handler)
            {
                // Handle normal function objects
                static if (isSomeFunction!dg)
                {
                    alias Params = Parameters!dg;
                    static if (Params.length == 0)
                    {
                        // Just check exception functions in the first
                        // inner iteration (over delegates)
                        if (tidx > 0)
                            continue;
                        else
                        {
                            if (result.exceptionFuncIdx != -1)
                                assert(false, "duplicate parameter-less (error-)function specified");
                            result.exceptionFuncIdx = dgidx;
                        }
                    }
                    else static if (is(Params[0] == T) || is(Unqual!(Params[0]) == T))
                    {
                        if (added)
                            assert(false, "duplicate overload specified for type '" ~ T.stringof ~ "'");

                        added = true;
                        result.indices[tidx] = dgidx;
                    }
                }
                else static if (isSomeFunction!(dg!T))
                {
                    assert(result.generalFuncIdx == -1 ||
                           result.generalFuncIdx == dgidx,
                           "Only one generic visitor function is allowed");
                    result.generalFuncIdx = dgidx;
                }
                // Handle composite visitors with opCall overloads
                else
                {
                    static assert(false, dg.stringof ~ " is not a function or delegate");
                }
            }

            if (!added)
                result.indices[tidx] = -1;
        }

        return result;
    }

    enum HandlerOverloadMap = visitGetOverloadMap();

    if (!variant.hasValue)
    {
        // Call the exception function. The HandlerOverloadMap
        // will have its exceptionFuncIdx field set to value != -1 if an
        // exception function has been specified; otherwise we just through an exception.
        static if (HandlerOverloadMap.exceptionFuncIdx != -1)
            return Handler[ HandlerOverloadMap.exceptionFuncIdx ]();
        else
            throw new VariantException("variant must hold a value before being visited.");
    }

    foreach (idx, T; AllowedTypes)
    {
        if (auto ptr = variant.peek!T)
        {
            enum dgIdx = HandlerOverloadMap.indices[idx];

            static if (dgIdx == -1)
            {
                static if (HandlerOverloadMap.generalFuncIdx >= 0)
                    return Handler[HandlerOverloadMap.generalFuncIdx](*ptr);
                else static if (Strict)
                    static assert(false, "overload for type '" ~ T.stringof ~ "' hasn't been specified");
                else static if (HandlerOverloadMap.exceptionFuncIdx != -1)
                    return Handler[HandlerOverloadMap.exceptionFuncIdx]();
                else
                    throw new VariantException(
                        "variant holds value of type '"
                        ~ T.stringof ~
                        "' but no visitor has been provided"
                    );
            }
            else
            {
                return Handler[ dgIdx ](*ptr);
            }
        }
    }

    assert(false);
}
