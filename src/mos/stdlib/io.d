module mos.stdlib.io;

import mos.objects;
import mos.stdlib.misc : invalidType, invalidArgc, invalidArgcRange;
import mos.misc;
import stdd.array;

import com.log;
mixin MOSModule!(mos.stdlib.io);

private enum formatChar = '@';
__gshared private{
    Module attrEnum;
}
void init() {
    attrEnum = mosenum!("Attr", mos.misc.Attr);
}
@mosexport Module Attr() { return attrEnum; }

@mosexport @mosmodule abstract class Console {
static:
    @mosexport {
        void setAttr() {
            mosattr();
        }
        void setAttr(mosint flags, mosint fg) {
            mosattr(cast(ubyte)flags, cast(uint)fg, mosGetBg());
        }
        void setAttr(mosint flags, mosint fg, mosint bg) {
            mosattr(cast(ubyte)flags, cast(uint)fg, cast(uint) bg);
        }

        @mosget mosint Flags() { return mosGetFlags(); }
        @mosset mosint Flags(mosint flags) { mosSetFlags(cast(ubyte) flags); return flags; }

        @mosget mosint Fg() { return mosGetFg(); }
        @mosset mosint Fg(mosint val) { mosSetFg(cast(uint) val); return val; }

        @mosget mosint Bg() { return mosGetBg(); }
        @mosset mosint Bg(mosint val) { mosSetBg(cast(uint) val); return val; }
        void clear() {mosclear(); }
        void puts(mosstring s) { mosputs(s); }
        void putnl() { mosputnl(); }
    }
}
@mosexport @mosmodule abstract class Color {
static:

    @mosexport @mosget {
        mosint Base00() { return colors.base00; }
        mosint Base01() { return colors.base01; }
        mosint Base02() { return colors.base02; }
        mosint Base03() { return colors.base03; }
        mosint Base04() { return colors.base04; }
        mosint Base05() { return colors.base05; }
        mosint Base06() { return colors.base06; }
        mosint Base07() { return colors.base07; }
        mosint Base08() { return colors.base08; }
        mosint Base09() { return colors.base09; }
        mosint Base0A() { return colors.base0A; }
        mosint Base0B() { return colors.base0B; }
        mosint Base0C() { return colors.base0C; }
        mosint Base0D() { return colors.base0D; }
        mosint Base0E() { return colors.base0E; }
        mosint Base0F() { return colors.base0F; }

        mosint BaseBlack()      { return Base00; }
        mosint BaseBackground() { return Base00; }
        mosint BaseDefault()    { return Base05; }
        mosint BaseDarkGrey()   { return Base01; }
        mosint BaseGrey()       { return Base02; }
        mosint BaseLightGrey()  { return Base03; }
        mosint BaseDarkGray()   { return Base01; }
        mosint BaseGray()       { return Base02; }
        mosint BaseLightGray()  { return Base03; }
        mosint BaseWhite()      { return Base07; }
        mosint BaseRed()        { return Base08; }
        mosint BaseOrange()     { return Base09; }
        mosint BaseYellow()     { return Base0A; }
        mosint BaseGreen()      { return Base0B; }
        mosint BaseCyan()       { return Base0C; }
        mosint BaseBlue()       { return Base0D; }
        mosint BasePurple()     { return Base0E; }
        mosint BaseBrown()      { return Base0F; }

        //css colors
        mosint AliceBlue()            { return 0xFFF0F8FF; }
        mosint AntiqueWhite()         { return 0xFFFAEBD7; }
        mosint Aqua()                 { return 0xFF00FFFF; }
        mosint Aquamarine()           { return 0xFF7FFFD4; }
        mosint Azure()                { return 0xFFF0FFFF; }
        mosint Beige()                { return 0xFFF5F5DC; }
        mosint Bisque()               { return 0xFFFFE4C4; }
        mosint Black()                { return 0xFF000000; }
        mosint BlanchedAlmond()       { return 0xFFFFEBCD; }
        mosint Blue()                 { return 0xFF0000FF; }
        mosint BlueViolet()           { return 0xFF8A2BE2; }
        mosint Brown()                { return 0xFFA52A2A; }
        mosint BurlyWood()            { return 0xFFDEB887; }
        mosint CadetBlue()            { return 0xFF5F9EA0; }
        mosint Chartreuse()           { return 0xFF7FFF00; }
        mosint Chocolate()            { return 0xFFD2691E; }
        mosint Coral()                { return 0xFFFF7F50; }
        mosint CornflowerBlue()       { return 0xFF6495ED; }
        mosint Cornsilk()             { return 0xFFFFF8DC; }
        mosint Crimson()              { return 0xFFDC143C; }
        mosint Cyan()                 { return 0xFF00FFFF; }
        mosint DarkBlue()             { return 0xFF00008B; }
        mosint DarkCyan()             { return 0xFF008B8B; }
        mosint DarkGoldenRod()        { return 0xFFB8860B; }
        mosint DarkGray()             { return 0xFFA9A9A9; }
        mosint DarkGrey()             { return 0xFFA9A9A9; }
        mosint DarkGreen()            { return 0xFF006400; }
        mosint DarkKhaki()            { return 0xFFBDB76B; }
        mosint DarkMagenta()          { return 0xFF8B008B; }
        mosint DarkOliveGreen()       { return 0xFF556B2F; }
        mosint DarkOrange()           { return 0xFFFF8C00; }
        mosint DarkOrchid()           { return 0xFF9932CC; }
        mosint DarkRed()              { return 0xFF8B0000; }
        mosint DarkSalmon()           { return 0xFFE9967A; }
        mosint DarkSeaGreen()         { return 0xFF8FBC8F; }
        mosint DarkSlateBlue()        { return 0xFF483D8B; }
        mosint DarkSlateGray()        { return 0xFF2F4F4F; }
        mosint DarkSlateGrey()        { return 0xFF2F4F4F; }
        mosint DarkTurquoise()        { return 0xFF00CED1; }
        mosint DarkViolet()           { return 0xFF9400D3; }
        mosint DeepPink()             { return 0xFFFF1493; }
        mosint DeepSkyBlue()          { return 0xFF00BFFF; }
        mosint DimGray()              { return 0xFF696969; }
        mosint DimGrey()              { return 0xFF696969; }
        mosint DodgerBlue()           { return 0xFF1E90FF; }
        mosint FireBrick()            { return 0xFFB22222; }
        mosint FloralWhite()          { return 0xFFFFFAF0; }
        mosint ForestGreen()          { return 0xFF228B22; }
        mosint Fuchsia()              { return 0xFFFF00FF; }
        mosint Gainsboro()            { return 0xFFDCDCDC; }
        mosint GhostWhite()           { return 0xFFF8F8FF; }
        mosint Gold()                 { return 0xFFFFD700; }
        mosint GoldenRod()            { return 0xFFDAA520; }
        mosint Gray()                 { return 0xFF808080; }
        mosint Grey()                 { return 0xFF808080; }
        mosint Green()                { return 0xFF008000; }
        mosint GreenYellow()          { return 0xFFADFF2F; }
        mosint HoneyDew()             { return 0xFFF0FFF0; }
        mosint HotPink()              { return 0xFFFF69B4; }
        mosint IndianRed()            { return 0xFFCD5C5C; }
        mosint Indigo()               { return 0xFF4B0082; }
        mosint Ivory()                { return 0xFFFFFFF0; }
        mosint Khaki()                { return 0xFFF0E68C; }
        mosint Lavender()             { return 0xFFE6E6FA; }
        mosint LavenderBlush()        { return 0xFFFFF0F5; }
        mosint LawnGreen()            { return 0xFF7CFC00; }
        mosint LemonChiffon()         { return 0xFFFFFACD; }
        mosint LightBlue()            { return 0xFFADD8E6; }
        mosint LightCoral()           { return 0xFFF08080; }
        mosint LightCyan()            { return 0xFFE0FFFF; }
        mosint LightGoldenRodYellow() { return 0xFFFAFAD2; }
        mosint LightGray()            { return 0xFFD3D3D3; }
        mosint LightGrey()            { return 0xFFD3D3D3; }
        mosint LightGreen()           { return 0xFF90EE90; }
        mosint LightPink()            { return 0xFFFFB6C1; }
        mosint LightSalmon()          { return 0xFFFFA07A; }
        mosint LightSeaGreen()        { return 0xFF20B2AA; }
        mosint LightSkyBlue()         { return 0xFF87CEFA; }
        mosint LightSlateGray()       { return 0xFF778899; }
        mosint LightSlateGrey()       { return 0xFF778899; }
        mosint LightSteelBlue()       { return 0xFFB0C4DE; }
        mosint LightYellow()          { return 0xFFFFFFE0; }
        mosint Lime()                 { return 0xFF00FF00; }
        mosint LimeGreen()            { return 0xFF32CD32; }
        mosint Linen()                { return 0xFFFAF0E6; }
        mosint Magenta()              { return 0xFFFF00FF; }
        mosint Maroon()               { return 0xFF800000; }
        mosint MediumAquaMarine()     { return 0xFF66CDAA; }
        mosint MediumBlue()           { return 0xFF0000CD; }
        mosint MediumOrchid()         { return 0xFFBA55D3; }
        mosint MediumPurple()         { return 0xFF9370DB; }
        mosint MediumSeaGreen()       { return 0xFF3CB371; }
        mosint MediumSlateBlue()      { return 0xFF7B68EE; }
        mosint MediumSpringGreen()    { return 0xFF00FA9A; }
        mosint MediumTurquoise()      { return 0xFF48D1CC; }
        mosint MediumVioletRed()      { return 0xFFC71585; }
        mosint MidnightBlue()         { return 0xFF191970; }
        mosint MintCream()            { return 0xFFF5FFFA; }
        mosint MistyRose()            { return 0xFFFFE4E1; }
        mosint Moccasin()             { return 0xFFFFE4B5; }
        mosint NavajoWhite()          { return 0xFFFFDEAD; }
        mosint Navy()                 { return 0xFF000080; }
        mosint OldLace()              { return 0xFFFDF5E6; }
        mosint Olive()                { return 0xFF808000; }
        mosint OliveDrab()            { return 0xFF6B8E23; }
        mosint Orange()               { return 0xFFFFA500; }
        mosint OrangeRed()            { return 0xFFFF4500; }
        mosint Orchid()               { return 0xFFDA70D6; }
        mosint PaleGoldenRod()        { return 0xFFEEE8AA; }
        mosint PaleGreen()            { return 0xFF98FB98; }
        mosint PaleTurquoise()        { return 0xFFAFEEEE; }
        mosint PaleVioletRed()        { return 0xFFDB7093; }
        mosint PapayaWhip()           { return 0xFFFFEFD5; }
        mosint PeachPuff()            { return 0xFFFFDAB9; }
        mosint Peru()                 { return 0xFFCD853F; }
        mosint Pink()                 { return 0xFFFFC0CB; }
        mosint Plum()                 { return 0xFFDDA0DD; }
        mosint PowderBlue()           { return 0xFFB0E0E6; }
        mosint Purple()               { return 0xFF800080; }
        mosint RebeccaPurple()        { return 0xFF663399; }
        mosint Red()                  { return 0xFFFF0000; }
        mosint RosyBrown()            { return 0xFFBC8F8F; }
        mosint RoyalBlue()            { return 0xFF4169E1; }
        mosint SaddleBrown()          { return 0xFF8B4513; }
        mosint Salmon()               { return 0xFFFA8072; }
        mosint SandyBrown()           { return 0xFFF4A460; }
        mosint SeaGreen()             { return 0xFF2E8B57; }
        mosint SeaShell()             { return 0xFFFFF5EE; }
        mosint Sienna()               { return 0xFFA0522D; }
        mosint Silver()               { return 0xFFC0C0C0; }
        mosint SkyBlue()              { return 0xFF87CEEB; }
        mosint SlateBlue()            { return 0xFF6A5ACD; }
        mosint SlateGray()            { return 0xFF708090; }
        mosint SlateGrey()            { return 0xFF708090; }
        mosint Snow()                 { return 0xFFFFFAFA; }
        mosint SpringGreen()          { return 0xFF00FF7F; }
        mosint SteelBlue()            { return 0xFF4682B4; }
        mosint Tan()                  { return 0xFFD2B48C; }
        mosint Teal()                 { return 0xFF008080; }
        mosint Thistle()              { return 0xFFD8BFD8; }
        mosint Tomato()               { return 0xFFFF6347; }
        mosint Turquoise()            { return 0xFF40E0D0; }
        mosint Violet()               { return 0xFFEE82EE; }
        mosint Wheat()                { return 0xFFF5DEB3; }
        mosint White()                { return 0xFFFFFFFF; }
        mosint WhiteSmoke()           { return 0xFFF5F5F5; }
        mosint Yellow()               { return 0xFFFFFF00; }
        mosint YellowGreen()          { return 0xFF9ACD32; }
    }
}

@mosexport {
    mosstring sprintf(Pos pos, Env env, mosstring fmt, Obj[] args) {
        Obj pop() {
            auto t = args.front();
            args.popFront();
            return t;
        }

        //auto str = pop().get!String(pos).val;
        size_t argc = args.length;
        size_t expectedArgc = 0;

        auto p = fmt.ptr;
        const end = p + fmt.length;
        mosstring res = "";
        for (; p != end; ++p) {
            if (*p != formatChar) {
                res ~= *p;
            }
            else if ((p + 1) != end && *(p + 1) == formatChar) {
                ++p;
                res ~= formatChar;
            }
            else {
                ++expectedArgc;
                if (args.length != 0)
                    res ~= pop().toStr(pos, env);
            }
        }
        if (argc != expectedArgc)
            invalidArgc(pos, argc, expectedArgc);
        return res;
    }

    void print(Pos p, Env e, Obj[] args) {
        foreach (a; args)
            mosputs(a.toStr(p, e));
    }
    void println(Pos p, Env e, Obj[] args) {
        print(p, e, args);
        mosputnl();//mosputs("\n");
    }
    void printf(Pos p, Env e, mosstring fmt, Obj[] args) {
        mosputs(sprintf(p, e, fmt, args));
    }
    void printfln(Pos p, Env e, mosstring fmt, Obj[] args) {
        mosputsln(sprintf(p, e, fmt, args));
    }
}
