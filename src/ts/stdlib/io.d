module ts.stdlib.io;

import ts.objects;
import ts.stdlib.misc : invalidType, invalidArgc, invalidArgcRange;
import ts.misc;
import stdd.array;

//enum types = ["Output"];
private enum formatChar = '@';
__gshared private{
    Module attrEnum;
}
public:
void init() {
    import com.log;
    tslog("<<init_io>>");
    attrEnum = tsenum!("Attr", ts.misc.Attr);
}
Module Attr() { return attrEnum; }

abstract class mod_console {
static:
    /*TypeMeta typeMeta;
      tsstring type() { return "Output"; }*/
    void setAttr() {
        tsattr();
    }
    void setAttr(tsint flags, tsint fg) {
        PropSet_Flags(flags);
        PropSet_Fg(fg);
    }

    void setAttr(tsint flags, tsint fg, tsint bg) {
        tsattr(cast(ubyte)flags, cast(uint)fg, cast(uint) bg);
    }
    tsint Prop_Flags() { return tsGetFlags(); }
    tsint PropSet_Flags(tsint flags) { tsSetFlags(cast(ubyte) flags); return flags; }

    tsint Prop_Fg() { return tsGetFg(); }
    tsint PropSet_Fg(tsint val) { tsSetFg(cast(uint) val); return val; }

    tsint Prop_Bg() { return tsGetBg(); }
    tsint PropSet_Bg(tsint val) { tsSetBg(cast(uint) val); return val; }
    void clear() {tsclear(); }
    void puts(tsstring s) { tsputs(s); }
    void putnl() { tsputnl(); }
}
abstract class mod_color {
static:
    tsint Base00() { return colors.base00; }
    tsint Base01() { return colors.base01; }
    tsint Base02() { return colors.base02; }
    tsint Base03() { return colors.base03; }
    tsint Base04() { return colors.base04; }
    tsint Base05() { return colors.base05; }
    tsint Base06() { return colors.base06; }
    tsint Base07() { return colors.base07; }
    tsint Base08() { return colors.base08; }
    tsint Base09() { return colors.base09; }
    tsint Base0A() { return colors.base0A; }
    tsint Base0B() { return colors.base0B; }
    tsint Base0C() { return colors.base0C; }
    tsint Base0D() { return colors.base0D; }
    tsint Base0E() { return colors.base0E; }
    tsint Base0F() { return colors.base0F; }

    tsint BaseBlack()      { return Base00; }
    tsint BaseBackground() { return Base00; }
    tsint BaseDefault()    { return Base05; }
    tsint BaseDarkGrey()   { return Base01; }
    tsint BaseGrey()       { return Base02; }
    tsint BaseLightGrey()  { return Base03; }
    tsint BaseDarkGray()   { return Base01; }
    tsint BaseGray()       { return Base02; }
    tsint BaseLightGray()  { return Base03; }
    tsint BaseWhite()      { return Base07; }
    tsint BaseRed()        { return Base08; }
    tsint BaseOrange()     { return Base09; }
    tsint BaseYellow()     { return Base0A; }
    tsint BaseGreen()      { return Base0B; }
    tsint BaseCyan()       { return Base0C; }
    tsint BaseBlue()       { return Base0D; }
    tsint BasePurple()     { return Base0E; }
    tsint BaseBrown()      { return Base0F; }

    //css colors
    tsint AliceBlue()            { return 0xFFF0F8FF; }
    tsint AntiqueWhite()         { return 0xFFFAEBD7; }
    tsint Aqua()                 { return 0xFF00FFFF; }
    tsint Aquamarine()           { return 0xFF7FFFD4; }
    tsint Azure()                { return 0xFFF0FFFF; }
    tsint Beige()                { return 0xFFF5F5DC; }
    tsint Bisque()               { return 0xFFFFE4C4; }
    tsint Black()                { return 0xFF000000; }
    tsint BlanchedAlmond()       { return 0xFFFFEBCD; }
    tsint Blue()                 { return 0xFF0000FF; }
    tsint BlueViolet()           { return 0xFF8A2BE2; }
    tsint Brown()                { return 0xFFA52A2A; }
    tsint BurlyWood()            { return 0xFFDEB887; }
    tsint CadetBlue()            { return 0xFF5F9EA0; }
    tsint Chartreuse()           { return 0xFF7FFF00; }
    tsint Chocolate()            { return 0xFFD2691E; }
    tsint Coral()                { return 0xFFFF7F50; }
    tsint CornflowerBlue()       { return 0xFF6495ED; }
    tsint Cornsilk()             { return 0xFFFFF8DC; }
    tsint Crimson()              { return 0xFFDC143C; }
    tsint Cyan()                 { return 0xFF00FFFF; }
    tsint DarkBlue()             { return 0xFF00008B; }
    tsint DarkCyan()             { return 0xFF008B8B; }
    tsint DarkGoldenRod()        { return 0xFFB8860B; }
    tsint DarkGray()             { return 0xFFA9A9A9; }
    tsint DarkGrey()             { return 0xFFA9A9A9; }
    tsint DarkGreen()            { return 0xFF006400; }
    tsint DarkKhaki()            { return 0xFFBDB76B; }
    tsint DarkMagenta()          { return 0xFF8B008B; }
    tsint DarkOliveGreen()       { return 0xFF556B2F; }
    tsint DarkOrange()           { return 0xFFFF8C00; }
    tsint DarkOrchid()           { return 0xFF9932CC; }
    tsint DarkRed()              { return 0xFF8B0000; }
    tsint DarkSalmon()           { return 0xFFE9967A; }
    tsint DarkSeaGreen()         { return 0xFF8FBC8F; }
    tsint DarkSlateBlue()        { return 0xFF483D8B; }
    tsint DarkSlateGray()        { return 0xFF2F4F4F; }
    tsint DarkSlateGrey()        { return 0xFF2F4F4F; }
    tsint DarkTurquoise()        { return 0xFF00CED1; }
    tsint DarkViolet()           { return 0xFF9400D3; }
    tsint DeepPink()             { return 0xFFFF1493; }
    tsint DeepSkyBlue()          { return 0xFF00BFFF; }
    tsint DimGray()              { return 0xFF696969; }
    tsint DimGrey()              { return 0xFF696969; }
    tsint DodgerBlue()           { return 0xFF1E90FF; }
    tsint FireBrick()            { return 0xFFB22222; }
    tsint FloralWhite()          { return 0xFFFFFAF0; }
    tsint ForestGreen()          { return 0xFF228B22; }
    tsint Fuchsia()              { return 0xFFFF00FF; }
    tsint Gainsboro()            { return 0xFFDCDCDC; }
    tsint GhostWhite()           { return 0xFFF8F8FF; }
    tsint Gold()                 { return 0xFFFFD700; }
    tsint GoldenRod()            { return 0xFFDAA520; }
    tsint Gray()                 { return 0xFF808080; }
    tsint Grey()                 { return 0xFF808080; }
    tsint Green()                { return 0xFF008000; }
    tsint GreenYellow()          { return 0xFFADFF2F; }
    tsint HoneyDew()             { return 0xFFF0FFF0; }
    tsint HotPink()              { return 0xFFFF69B4; }
    tsint IndianRed()            { return 0xFFCD5C5C; }
    tsint Indigo()               { return 0xFF4B0082; }
    tsint Ivory()                { return 0xFFFFFFF0; }
    tsint Khaki()                { return 0xFFF0E68C; }
    tsint Lavender()             { return 0xFFE6E6FA; }
    tsint LavenderBlush()        { return 0xFFFFF0F5; }
    tsint LawnGreen()            { return 0xFF7CFC00; }
    tsint LemonChiffon()         { return 0xFFFFFACD; }
    tsint LightBlue()            { return 0xFFADD8E6; }
    tsint LightCoral()           { return 0xFFF08080; }
    tsint LightCyan()            { return 0xFFE0FFFF; }
    tsint LightGoldenRodYellow() { return 0xFFFAFAD2; }
    tsint LightGray()            { return 0xFFD3D3D3; }
    tsint LightGrey()            { return 0xFFD3D3D3; }
    tsint LightGreen()           { return 0xFF90EE90; }
    tsint LightPink()            { return 0xFFFFB6C1; }
    tsint LightSalmon()          { return 0xFFFFA07A; }
    tsint LightSeaGreen()        { return 0xFF20B2AA; }
    tsint LightSkyBlue()         { return 0xFF87CEFA; }
    tsint LightSlateGray()       { return 0xFF778899; }
    tsint LightSlateGrey()       { return 0xFF778899; }
    tsint LightSteelBlue()       { return 0xFFB0C4DE; }
    tsint LightYellow()          { return 0xFFFFFFE0; }
    tsint Lime()                 { return 0xFF00FF00; }
    tsint LimeGreen()            { return 0xFF32CD32; }
    tsint Linen()                { return 0xFFFAF0E6; }
    tsint Magenta()              { return 0xFFFF00FF; }
    tsint Maroon()               { return 0xFF800000; }
    tsint MediumAquaMarine()     { return 0xFF66CDAA; }
    tsint MediumBlue()           { return 0xFF0000CD; }
    tsint MediumOrchid()         { return 0xFFBA55D3; }
    tsint MediumPurple()         { return 0xFF9370DB; }
    tsint MediumSeaGreen()       { return 0xFF3CB371; }
    tsint MediumSlateBlue()      { return 0xFF7B68EE; }
    tsint MediumSpringGreen()    { return 0xFF00FA9A; }
    tsint MediumTurquoise()      { return 0xFF48D1CC; }
    tsint MediumVioletRed()      { return 0xFFC71585; }
    tsint MidnightBlue()         { return 0xFF191970; }
    tsint MintCream()            { return 0xFFF5FFFA; }
    tsint MistyRose()            { return 0xFFFFE4E1; }
    tsint Moccasin()             { return 0xFFFFE4B5; }
    tsint NavajoWhite()          { return 0xFFFFDEAD; }
    tsint Navy()                 { return 0xFF000080; }
    tsint OldLace()              { return 0xFFFDF5E6; }
    tsint Olive()                { return 0xFF808000; }
    tsint OliveDrab()            { return 0xFF6B8E23; }
    tsint Orange()               { return 0xFFFFA500; }
    tsint OrangeRed()            { return 0xFFFF4500; }
    tsint Orchid()               { return 0xFFDA70D6; }
    tsint PaleGoldenRod()        { return 0xFFEEE8AA; }
    tsint PaleGreen()            { return 0xFF98FB98; }
    tsint PaleTurquoise()        { return 0xFFAFEEEE; }
    tsint PaleVioletRed()        { return 0xFFDB7093; }
    tsint PapayaWhip()           { return 0xFFFFEFD5; }
    tsint PeachPuff()            { return 0xFFFFDAB9; }
    tsint Peru()                 { return 0xFFCD853F; }
    tsint Pink()                 { return 0xFFFFC0CB; }
    tsint Plum()                 { return 0xFFDDA0DD; }
    tsint PowderBlue()           { return 0xFFB0E0E6; }
    tsint Purple()               { return 0xFF800080; }
    tsint RebeccaPurple()        { return 0xFF663399; }
    tsint Red()                  { return 0xFFFF0000; }
    tsint RosyBrown()            { return 0xFFBC8F8F; }
    tsint RoyalBlue()            { return 0xFF4169E1; }
    tsint SaddleBrown()          { return 0xFF8B4513; }
    tsint Salmon()               { return 0xFFFA8072; }
    tsint SandyBrown()           { return 0xFFF4A460; }
    tsint SeaGreen()             { return 0xFF2E8B57; }
    tsint SeaShell()             { return 0xFFFFF5EE; }
    tsint Sienna()               { return 0xFFA0522D; }
    tsint Silver()               { return 0xFFC0C0C0; }
    tsint SkyBlue()              { return 0xFF87CEEB; }
    tsint SlateBlue()            { return 0xFF6A5ACD; }
    tsint SlateGray()            { return 0xFF708090; }
    tsint SlateGrey()            { return 0xFF708090; }
    tsint Snow()                 { return 0xFFFFFAFA; }
    tsint SpringGreen()          { return 0xFF00FF7F; }
    tsint SteelBlue()            { return 0xFF4682B4; }
    tsint Tan()                  { return 0xFFD2B48C; }
    tsint Teal()                 { return 0xFF008080; }
    tsint Thistle()              { return 0xFFD8BFD8; }
    tsint Tomato()               { return 0xFFFF6347; }
    tsint Turquoise()            { return 0xFF40E0D0; }
    tsint Violet()               { return 0xFFEE82EE; }
    tsint Wheat()                { return 0xFFF5DEB3; }
    tsint White()                { return 0xFFFFFFFF; }
    tsint WhiteSmoke()           { return 0xFFF5F5F5; }
    tsint Yellow()               { return 0xFFFFFF00; }
    tsint YellowGreen()          { return 0xFF9ACD32; }
}


tsstring sprintf(Pos pos, Env env, tsstring fmt, Obj[] args) {
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
    tsstring res = "";
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
        tsputs(a.toStr(p, e));
}
void println(Pos p, Env e, Obj[] args) {
    print(p, e, args);
    tsputnl();//tsputs("\n");
}
void printf(Pos p, Env e, tsstring fmt, Obj[] args) {
    tsputs(sprintf(p, e, fmt, args));
}
void printfln(Pos p, Env e, tsstring fmt, Obj[] args) {
    tsputsln(sprintf(p, e, fmt, args));
}
