// Written in the D programming language.

/++
    Functions which operate on ASCII characters.

    All of the functions in stdd._ascii accept Unicode characters but
    effectively ignore them if they're not ASCII. All `isX` functions return
    `false` for non-ASCII characters, and all `toX` functions do nothing
    to non-ASCII characters.

    For functions which operate on Unicode characters, see
    $(MREF stdd, uni).

$(SCRIPT inhibitQuickIndex = 1;)
$(DIVC quickindex,
$(BOOKTABLE,
$(TR $(TH Category) $(TH Functions))
$(TR $(TD Validation) $(TD
        $(LREF isAlpha)
        $(LREF isAlphaNum)
        $(LREF isASCII)
        $(LREF isControl)
        $(LREF isDigit)
        $(LREF isGraphical)
        $(LREF isHexDigit)
        $(LREF isOctalDigit)
        $(LREF isPrintable)
        $(LREF isPunctuation)
        $(LREF isUpper)
        $(LREF isWhite)
))
$(TR $(TD Conversions) $(TD
        $(LREF toLower)
        $(LREF toUpper)
))
$(TR $(TD Constants) $(TD
        $(LREF digits)
        $(LREF fullHexDigits)
        $(LREF hexDigits)
        $(LREF letters)
        $(LREF lowercase)
        $(LREF lowerHexDigits)
        $(LREF newline)
        $(LREF octalDigits)
        $(LREF uppercase)
        $(LREF whitespace)
))
$(TR $(TD Enums) $(TD
        $(LREF LetterCase)
))
))
    References:
        $(LINK2 http://www.digitalmars.com/d/ascii-table.html, ASCII Table),
        $(HTTP en.wikipedia.org/wiki/Ascii, Wikipedia)

    License:   $(HTTP www.boost.org/LICENSE_1_0.txt, Boost License 1.0).
    Authors:   $(HTTP digitalmars.com, Walter Bright) and
               $(HTTP jmdavisprog.com, Jonathan M Davis)
    Source:    $(PHOBOSSRC stdd/_ascii.d)
  +/
module stdd.ascii;

immutable fullHexDigits  = "0123456789ABCDEFabcdef";     /// 0 .. 9A .. Fa .. f
immutable hexDigits      = fullHexDigits[0 .. 16];         /// 0 .. 9A .. F
immutable lowerHexDigits = "0123456789abcdef";           /// 0 .. 9a .. f
immutable digits         = hexDigits[0 .. 10];             /// 0 .. 9
immutable octalDigits    = digits[0 .. 8];                 /// 0 .. 7
immutable letters        = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"; /// A .. Za .. z
immutable uppercase      = letters[0 .. 26];               /// A .. Z
immutable lowercase      = letters[26 .. 52];              /// a .. z
immutable whitespace     = " \t\v\r\n\f";                /// ASCII _whitespace

/++
    Letter case specifier.
  +/
enum LetterCase : bool
{
    upper, /// Upper case letters
    lower  /// Lower case letters
}


/// Newline sequence for this system.
version(Windows)
    immutable newline = "\r\n";
else version(Posix)
    immutable newline = "\n";
else
    static assert(0, "Unsupported OS");


/++
    Params: c = The character to test.
    Returns: Whether `c` is a letter or a number (0 .. 9, a .. z, A .. Z).
  +/
bool isAlphaNum(dchar c) @safe pure nothrow @nogc
{
    return c <= 'z' && c >= '0' && (c <= '9' || c >= 'a' || (c >= 'A' && c <= 'Z'));
}

///
@safe pure nothrow @nogc unittest
{
    assert( isAlphaNum('A'));
    assert( isAlphaNum('1'));
    assert(!isAlphaNum('#'));

    // N.B.: does not return true for non-ASCII Unicode alphanumerics:
    assert(!isAlphaNum('á'));
}

/++
    Params: c = The character to test.
    Returns: Whether `c` is an ASCII letter (A .. Z, a .. z).
  +/
bool isAlpha(dchar c) @safe pure nothrow @nogc
{
    // Optimizer can turn this into a bitmask operation on 64 bit code
    return (c >= 'A' && c <= 'Z') || (c >= 'a' && c <= 'z');
}

///
@safe pure nothrow @nogc unittest
{
    assert( isAlpha('A'));
    assert(!isAlpha('1'));
    assert(!isAlpha('#'));

    // N.B.: does not return true for non-ASCII Unicode alphabetic characters:
    assert(!isAlpha('á'));
}


/++
    Params: c = The character to test.
    Returns: Whether `c` is a lowercase ASCII letter (a .. z).
  +/
bool isLower(dchar c) @safe pure nothrow @nogc
{
    return c >= 'a' && c <= 'z';
}

///
@safe pure nothrow @nogc unittest
{
    assert( isLower('a'));
    assert(!isLower('A'));
    assert(!isLower('#'));

    // N.B.: does not return true for non-ASCII Unicode lowercase letters
    assert(!isLower('á'));
    assert(!isLower('Á'));
}


/++
    Params: c = The character to test.
    Returns: Whether `c` is an uppercase ASCII letter (A .. Z).
  +/
bool isUpper(dchar c) @safe pure nothrow @nogc
{
    return c <= 'Z' && 'A' <= c;
}

///
@safe pure nothrow @nogc unittest
{
    assert( isUpper('A'));
    assert(!isUpper('a'));
    assert(!isUpper('#'));

    // N.B.: does not return true for non-ASCII Unicode uppercase letters
    assert(!isUpper('á'));
    assert(!isUpper('Á'));
}


/++
    Params: c = The character to test.
    Returns: Whether `c` is a digit (0 .. 9).
  +/
bool isDigit(dchar c) @safe pure nothrow @nogc
{
    return '0' <= c && c <= '9';
}

///
@safe pure nothrow @nogc unittest
{
    assert( isDigit('3'));
    assert( isDigit('8'));
    assert(!isDigit('B'));
    assert(!isDigit('#'));

    // N.B.: does not return true for non-ASCII Unicode numbers
    assert(!isDigit('０')); // full-width digit zero (U+FF10)
    assert(!isDigit('４')); // full-width digit four (U+FF14)
}



/++
    Params: c = The character to test.
    Returns: Whether `c` is a digit in base 8 (0 .. 7).
  +/
bool isOctalDigit(dchar c) @safe pure nothrow @nogc
{
    return c >= '0' && c <= '7';
}

///
@safe pure nothrow @nogc unittest
{
    assert( isOctalDigit('0'));
    assert( isOctalDigit('7'));
    assert(!isOctalDigit('8'));
    assert(!isOctalDigit('A'));
    assert(!isOctalDigit('#'));
}


/++
    Params: c = The character to test.
    Returns: Whether `c` is a digit in base 16 (0 .. 9, A .. F, a .. f).
  +/
bool isHexDigit(dchar c) @safe pure nothrow @nogc
{
    return c <= 'f' && c >= '0' && (c <= '9' || c >= 'a' || (c >= 'A' && c <= 'F'));
}

///
@safe pure nothrow @nogc unittest
{
    assert( isHexDigit('0'));
    assert( isHexDigit('A'));
    assert( isHexDigit('f')); // lowercase hex digits are accepted
    assert(!isHexDigit('g'));
    assert(!isHexDigit('G'));
    assert(!isHexDigit('#'));
}



/++
    Params: c = The character to test.
    Returns: Whether or not `c` is a whitespace character. That includes the
    space, tab, vertical tab, form feed, carriage return, and linefeed
    characters.
  +/
bool isWhite(dchar c) @safe pure nothrow @nogc
{
    return c == ' ' || (c >= 0x09 && c <= 0x0D);
}

///

/++
    Params: c = The character to test.
    Returns: Whether `c` is a control character.
  +/
bool isControl(dchar c) @safe pure nothrow @nogc
{
    return c < 0x20 || c == 0x7F;
}

///
@safe pure nothrow @nogc unittest
{
    assert( isControl('\0'));
    assert( isControl('\022'));
    assert( isControl('\n')); // newline is both whitespace and control
    assert(!isControl(' '));
    assert(!isControl('1'));
    assert(!isControl('a'));
    assert(!isControl('#'));

    // N.B.: non-ASCII Unicode control characters are not recognized:
    assert(!isControl('\u0080'));
    assert(!isControl('\u2028'));
    assert(!isControl('\u2029'));
}


/++
    Params: c = The character to test.
    Returns: Whether or not `c` is a punctuation character. That includes
    all ASCII characters which are not control characters, letters, digits, or
    whitespace.
  +/
bool isPunctuation(dchar c) @safe pure nothrow @nogc
{
    return c <= '~' && c >= '!' && !isAlphaNum(c);
}

///
@safe pure nothrow @nogc unittest
{
    assert( isPunctuation('.'));
    assert( isPunctuation(','));
    assert( isPunctuation(':'));
    assert( isPunctuation('!'));
    assert( isPunctuation('#'));
    assert( isPunctuation('~'));
    assert( isPunctuation('+'));
    assert( isPunctuation('_'));

    assert(!isPunctuation('1'));
    assert(!isPunctuation('a'));
    assert(!isPunctuation(' '));
    assert(!isPunctuation('\n'));
    assert(!isPunctuation('\0'));

    // N.B.: Non-ASCII Unicode punctuation characters are not recognized.
    assert(!isPunctuation('\u2012')); // (U+2012 = en-dash)
}

@safe unittest
{
    foreach (dchar c; 0 .. 128)
    {
        if (isControl(c) || isAlphaNum(c) || c == ' ')
            assert(!isPunctuation(c));
        else
            assert(isPunctuation(c));
    }
}


/++
    Params: c = The character to test.
    Returns: Whether or not `c` is a printable character other than the
    space character.
  +/
bool isGraphical(dchar c) @safe pure nothrow @nogc
{
    return '!' <= c && c <= '~';
}

///
@safe pure nothrow @nogc unittest
{
    assert( isGraphical('1'));
    assert( isGraphical('a'));
    assert( isGraphical('#'));
    assert(!isGraphical(' ')); // whitespace is not graphical
    assert(!isGraphical('\n'));
    assert(!isGraphical('\0'));

    // N.B.: Unicode graphical characters are not regarded as such.
    assert(!isGraphical('á'));
}

@safe unittest
{
    foreach (dchar c; 0 .. 128)
    {
        if (isControl(c) || c == ' ')
            assert(!isGraphical(c));
        else
            assert(isGraphical(c));
    }
}


/++
    Params: c = The character to test.
    Returns: Whether or not `c` is a printable character - including the
    space character.
  +/
bool isPrintable(dchar c) @safe pure nothrow @nogc
{
    return c >= ' ' && c <= '~';
}

///
@safe pure nothrow @nogc unittest
{
    assert( isPrintable(' '));  // whitespace is printable
    assert( isPrintable('1'));
    assert( isPrintable('a'));
    assert( isPrintable('#'));
    assert(!isPrintable('\0')); // control characters are not printable

    // N.B.: Printable non-ASCII Unicode characters are not recognized.
    assert(!isPrintable('á'));
}

@safe unittest
{
    foreach (dchar c; 0 .. 128)
    {
        if (isControl(c))
            assert(!isPrintable(c));
        else
            assert(isPrintable(c));
    }
}


/++
    Params: c = The character to test.
    Returns: Whether or not `c` is in the ASCII character set - i.e. in the
    range 0 .. 0x7F.
  +/
pragma(inline, true)
bool isASCII(dchar c) @safe pure nothrow @nogc
{
    return c <= 0x7F;
}

///
@safe pure nothrow @nogc unittest
{
    assert( isASCII('a'));
    assert(!isASCII('á'));
}

@safe unittest
{
    foreach (dchar c; 0 .. 128)
        assert(isASCII(c));

    assert(!isASCII(128));
}


/++
    Converts an ASCII letter to lowercase.

    Params: c = A character of any type that implicitly converts to `dchar`.
    In the case where it's a built-in type, or an enum of a built-in type,
    `Unqual!(OriginalType!C)` is returned, whereas if it's a user-defined
    type, `dchar` is returned.

    Returns: The corresponding lowercase letter, if `c` is an uppercase
    ASCII character, otherwise `c` itself.
  +/
auto toLower(C)(C c)
if (is(C : dchar))
{
    import stdd.traits : isAggregateType, OriginalType, Unqual;

    alias OC = OriginalType!C;
    static if (isAggregateType!OC)
        alias R = dchar;
    else
        alias R = Unqual!OC;

    return isUpper(c) ? cast(R)(cast(R) c + 'a' - 'A') : cast(R) c;
}

///
@safe pure nothrow @nogc unittest
{
    assert(toLower('a') == 'a');
    assert(toLower('A') == 'a');
    assert(toLower('#') == '#');

    // N.B.: Non-ASCII Unicode uppercase letters are not converted.
    assert(toLower('Á') == 'Á');
}

@safe pure nothrow unittest
{

    import stdd.meta;
    static foreach (C; AliasSeq!(char, wchar, dchar, immutable char, ubyte))
    {
        foreach (i, c; uppercase)
            assert(toLower(cast(C) c) == lowercase[i]);

        foreach (C c; 0 .. 128)
        {
            if (c < 'A' || c > 'Z')
                assert(toLower(c) == c);
            else
                assert(toLower(c) != c);
        }

        foreach (C c; 128 .. C.max)
            assert(toLower(c) == c);

        //CTFE
        static assert(toLower(cast(C)'a') == 'a');
        static assert(toLower(cast(C)'A') == 'a');
    }
}


/++
    Converts an ASCII letter to uppercase.

    Params: c = Any type which implicitly converts to `dchar`. In the case
    where it's a built-in type, or an enum of a built-in type,
    `Unqual!(OriginalType!C)` is returned, whereas if it's a user-defined
    type, `dchar` is returned.

    Returns: The corresponding uppercase letter, if `c` is a lowercase ASCII
    character, otherwise `c` itself.
  +/
auto toUpper(C)(C c)
if (is(C : dchar))
{
    import stdd.traits : isAggregateType, OriginalType, Unqual;

    alias OC = OriginalType!C;
    static if (isAggregateType!OC)
        alias R = dchar;
    else
        alias R = Unqual!OC;

    return isLower(c) ? cast(R)(cast(R) c - ('a' - 'A')) : cast(R) c;
}

///
@safe pure nothrow @nogc unittest
{
    assert(toUpper('a') == 'A');
    assert(toUpper('A') == 'A');
    assert(toUpper('#') == '#');

    // N.B.: Non-ASCII Unicode lowercase letters are not converted.
    assert(toUpper('á') == 'á');
}


