/** 
 * Color picker based on Material Design colors: https://materialui.co/colors/ 
 */
class N7_ColorManager extends Core.Object
    config(N7CommandManager);

struct ColorPalette
{
    var string ID;
    var Color T50, T100, T200, T300, T400, T500, T600, T700, T800, T900;
    var Color A100, A200, A400, A700;
};

var protected config const ColorPalette Reds;
var protected config const ColorPalette Pinks;
var protected config const ColorPalette Purples;
var protected config const ColorPalette DeepPurples;
var protected config const ColorPalette Indigos;
var protected config const ColorPalette Blues;
var protected config const ColorPalette LightBlues;
var protected config const ColorPalette Cyans;
var protected config const ColorPalette Teals;
var protected config const ColorPalette Greens;
var protected config const ColorPalette LightGreens;
var protected config const ColorPalette Limes;
var protected config const ColorPalette Yellows;
var protected config const ColorPalette Ambers;
var protected config const ColorPalette Oranges;
var protected config const ColorPalette DeepOranges;
var protected config const ColorPalette Browns;
var protected config const ColorPalette Greys;
var protected config const ColorPalette BlueGreys;

var protected const Color White;
var protected const Color Black;

var protected config const Color DefaultColor;

/****************************
 *  PUBLIC INTERFACE
 ****************************/

public static function string TextRGBA(
    string Text, Color SelectedColor, optional bool bSkipColorRestore)
{
    local string ColorCode, DefaultColorCode;
    ColorCode = class'Engine.GameInfo'.static.MakeColorCode(SelectedColor);
    DefaultColorCode = class'Engine.GameInfo'.static.MakeColorCode(default.DefaultColor);

    if (!bSkipColorRestore)
    {
        return ColorCode $ Text $ DefaultColorCode;
    }

    return ColorCode $ Text;
}

/**
 * Get Color by ID of the following format:
 * <COLOR>:<TINT> | "BLACK" | "WHITE"
 * RGB format strings are also supported
 */
public static function Color GetColor(string ColorID)
{
    local Array<string> IDParts;
    local string ColorStr, Tint;
    local ColorPalette Palette;

    if (ColorID ~= "black")
        return default.Black;
    if (ColorID ~= "white")
        return default.White;
    
    if (IsRGBFormatColor(ColorID))
        return GetCustomColor(ColorID);

    Split(Locs(ColorID), ":", IDParts);

    if (IDParts.Length != 2)
        return default.DefaultColor;

    ColorStr = IDParts[0];
    Tint = IDParts[1];

    switch (ColorStr)
    {
        case default.Reds.ID:
            Palette = default.Reds;
            break;

        case default.Pinks.ID:
            Palette = default.Pinks;
            break;

        case default.Purples.ID:
            Palette = default.Purples;
            break;

        case default.DeepPurples.ID:
            Palette = default.DeepPurples;
            break;
        
        case default.Indigos.ID:
            Palette = default.Indigos;
            break;

        case default.Blues.ID:
            Palette = default.Blues;
            break;
        
        case default.LightBlues.ID:
            Palette = default.LightBlues;
            break;

        case default.Cyans.ID:
            Palette = default.Cyans;
            break;
        
        case default.Teals.ID:
            Palette = default.Teals;
            break;
        
        case default.Greens.ID:
            Palette = default.Greens;
            break;

        case default.LightGreens.ID:
            Palette = default.LightGreens;
            break;

        case default.Limes.ID:
            Palette = default.Limes;
            break;

        case default.Yellows.ID:
            Palette = default.Yellows;
            break;

        case default.Ambers.ID:
            Palette = default.Ambers;
            break;

        case default.Oranges.ID:
            Palette = default.Oranges;
            break;

        case default.DeepOranges.ID:
            Palette = default.DeepOranges;
            break;

        case default.Browns.ID:
            Palette = default.Browns;
            break;

        case default.Greys.ID:
            Palette = default.Greys;
            break;

        case default.BlueGreys.ID:
            Palette = default.BlueGreys;
            break;

        default:
            return default.DefaultColor;
    }

    switch (Tint)
    {
        case "50":      return Palette.T50;
        case "100":     return Palette.T100;
        case "200":     return Palette.T200;
        case "300":     return Palette.T300;
        case "400":     return Palette.T400;
        case "500":     return Palette.T500;
        case "600":     return Palette.T600;
        case "700":     return Palette.T700;
        case "800":     return Palette.T800;
        case "900":     return Palette.T900;
        case "a100":    return Palette.A100;
        case "a200":    return Palette.A200;
        case "a400":    return Palette.A400;
        case "a700":    return Palette.A700;

        default:        return Palette.T400;
    }
}

/****************************
 *  IMPLEMENTATION
 ****************************/

protected static function bool IsByte(string ByteStr)
{
    local int i;
    local string Char;

    if (Len(ByteStr) <= 0 || Len(ByteStr) > 3)
    {
        return false;
    }

    for (i = 0; i < Len(ByteStr); i++)
    {
        Char = Mid(ByteStr, i, 1);

        if (Char < "0" || Char > "9")
        {
            return false;
        }
    }

    if (int(ByteStr) < 0 || int(ByteStr) > 255)
    {
        return false;
    }

    return true;
}

protected static function bool IsRGBFormatColor(string ColorStr)
{
    local string ColorLowercaseStr;
    ColorLowercaseStr = Repl(Locs(ColorStr), " ", "");

    return Left(ColorLowercaseStr, 4) == "rgb(" && Right(ColorLowercaseStr, 1) == ")";
}

protected static function Array<string> ExtractBytesFromRGBString(string RGBString)
{
    local Array<string> RGBValues;
    local string TrimmedColorStr;

    TrimmedColorStr = Repl(Locs(RGBString), " ", "");
    TrimmedColorStr = Repl(TrimmedColorStr, "rgb(", "");
    TrimmedColorStr = Repl(TrimmedColorStr, ")", "");

    Split(TrimmedColorStr, ",", RGBValues);

    if (RGBValues.Length != 3 || !IsByte(RGBValues[0]) || !IsByte(RGBValues[1]) || !IsByte(RGBValues[2]))
    {
        RGBValues[0] = "0";
        RGBValues[1] = "0";
        RGBValues[2] = "0";

        RGBValues.Remove(3, RGBValues.Length - 3);
    }

    return RGBValues;
}

/** Only rgb(byte, byte, byte) compliant colors are considered valid */
protected static function Color GetCustomColor(string ColorStr)
{
    local Color CustomColor;
    local Array<string> RGBValues;
    RGBValues = ExtractBytesFromRGBString(ColorStr);

    CustomColor.R = int(RGBValues[0]);
    CustomColor.G = int(RGBValues[1]);
    CustomColor.B = int(RGBValues[2]);
    CustomColor.A = 255;

    return CustomColor;
}

defaultproperties
{
    White=(R=255,G=255,B=255,A=255)
    Black=(R=0,G=0,B=0,A=255)
    DefaultColor=(R=255,G=255,B=255,A=255)
    Reds=(ID="red",T50=(R=255,G=235,B=238,A=255),T100=(R=255,G=205,B=210,A=255),T200=(R=239,G=154,B=154,A=255),T300=(R=229,G=115,B=115,A=255),T400=(R=239,G=83,B=80,A=255),T500=(R=244,G=67,B=54,A=255),T600=(R=229,G=57,B=53,A=255),T700=(R=211,G=47,B=47,A=255),T800=(R=198,G=40,B=40,A=255),T900=(R=183,G=28,B=28,A=255),A100=(R=255,G=138,B=128,A=255),A200=(R=255,G=82,B=82,A=255),A400=(R=255,G=23,B=68,A=255),A700=(R=213,G=0,B=0,A=255))
    Pinks=(ID="pink",T50=(R=252,G=228,B=236,A=255),T100=(R=248,G=187,B=208,A=255),T200=(R=244,G=143,B=177,A=255),T300=(R=240,G=98,B=146,A=255),T400=(R=236,G=64,B=122,A=255),T500=(R=233,G=30,B=99,A=255),T600=(R=216,G=27,B=96,A=255),T700=(R=194,G=24,B=91,A=255),T800=(R=173,G=20,B=87,A=255),T900=(R=136,G=14,B=79,A=255),A100=(R=255,G=128,B=171,A=255),A200=(R=255,G=64,B=129,A=255),A400=(R=245,G=0,B=87,A=255),A700=(R=197,G=17,B=98,A=255))
    Purples=(ID="purple",T50=(R=243,G=229,B=245,A=255),T100=(R=225,G=190,B=231,A=255),T200=(R=206,G=147,B=216,A=255),T300=(R=186,G=104,B=200,A=255),T400=(R=171,G=71,B=188,A=255),T500=(R=156,G=39,B=176,A=255),T600=(R=142,G=36,B=170,A=255),T700=(R=123,G=31,B=162,A=255),T800=(R=106,G=27,B=154,A=255),T900=(R=74,G=20,B=140,A=255),A100=(R=234,G=128,B=252,A=255),A200=(R=224,G=64,B=251,A=255),A400=(R=213,G=0,B=249,A=255),A700=(R=170,G=0,B=255,A=255))
    DeepPurples=(ID="deeppurple",T50=(R=237,G=231,B=246,A=255),T100=(R=209,G=196,B=233,A=255),T200=(R=179,G=157,B=219,A=255),T300=(R=149,G=117,B=205,A=255),T400=(R=126,G=87,B=194,A=255),T500=(R=103,G=58,B=183,A=255),T600=(R=94,G=53,B=177,A=255),T700=(R=81,G=45,B=168,A=255),T800=(R=69,G=39,B=160,A=255),T900=(R=49,G=27,B=146,A=255),A100=(R=179,G=136,B=255,A=255),A200=(R=124,G=77,B=255,A=255),A400=(R=101,G=31,B=255,A=255),A700=(R=98,G=0,B=234,A=255))
    Indigos=(ID="indigo",T50=(R=232,G=234,B=246,A=255),T100=(R=197,G=202,B=233,A=255),T200=(R=159,G=168,B=218,A=255),T300=(R=121,G=134,B=203,A=255),T400=(R=92,G=107,B=192,A=255),T500=(R=63,G=81,B=181,A=255),T600=(R=57,G=73,B=171,A=255),T700=(R=48,G=63,B=159,A=255),T800=(R=40,G=53,B=147,A=255),T900=(R=26,G=35,B=126,A=255),A100=(R=140,G=158,B=255,A=255),A200=(R=83,G=109,B=254,A=255),A400=(R=61,G=90,B=254,A=255),A700=(R=48,G=79,B=254,A=255))
    Blues=(ID="blue",T50=(R=227,G=242,B=253,A=255),T100=(R=187,G=222,B=251,A=255),T200=(R=144,G=202,B=249,A=255),T300=(R=100,G=181,B=246,A=255),T400=(R=66,G=165,B=245,A=255),T500=(R=33,G=150,B=243,A=255),T600=(R=30,G=136,B=229,A=255),T700=(R=25,G=118,B=210,A=255),T800=(R=21,G=101,B=192,A=255),T900=(R=13,G=71,B=161,A=255),A100=(R=130,G=177,B=255,A=255),A200=(R=68,G=138,B=255,A=255),A400=(R=41,G=121,B=255,A=255),A700=(R=41,G=98,B=255,A=255))
    LightBlues=(ID="lightblue",T50=(R=225,G=245,B=254,A=255),T100=(R=179,G=229,B=252,A=255),T200=(R=129,G=212,B=250,A=255),T300=(R=79,G=195,B=247,A=255),T400=(R=41,G=182,B=246,A=255),T500=(R=3,G=169,B=244,A=255),T600=(R=3,G=155,B=229,A=255),T700=(R=2,G=136,B=209,A=255),T800=(R=2,G=119,B=189,A=255),T900=(R=1,G=87,B=155,A=255),A100=(R=128,G=216,B=255,A=255),A200=(R=64,G=196,B=255,A=255),A400=(R=0,G=176,B=255,A=255),A700=(R=0,G=145,B=234,A=255))
    Cyans=(ID="cyan",T50=(R=224,G=247,B=250,A=255),T100=(R=178,G=235,B=242,A=255),T200=(R=128,G=222,B=234,A=255),T300=(R=77,G=208,B=225,A=255),T400=(R=38,G=198,B=218,A=255),T500=(R=0,G=188,B=212,A=255),T600=(R=0,G=172,B=193,A=255),T700=(R=0,G=151,B=167,A=255),T800=(R=0,G=131,B=143,A=255),T900=(R=0,G=96,B=100,A=255),A100=(R=132,G=255,B=255,A=255),A200=(R=24,G=255,B=255,A=255),A400=(R=0,G=229,B=255,A=255),A700=(R=0,G=184,B=212,A=255))
    Teals=(ID="teal",T50=(R=224,G=242,B=241,A=255),T100=(R=178,G=223,B=219,A=255),T200=(R=128,G=203,B=196,A=255),T300=(R=77,G=182,B=172,A=255),T400=(R=38,G=166,B=154,A=255),T500=(R=0,G=150,B=136,A=255),T600=(R=0,G=137,B=123,A=255),T700=(R=0,G=121,B=107,A=255),T800=(R=0,G=105,B=92,A=255),T900=(R=0,G=77,B=64,A=255),A100=(R=167,G=255,B=235,A=255),A200=(R=100,G=255,B=218,A=255),A400=(R=29,G=233,B=182,A=255),A700=(R=0,G=191,B=165,A=255))
    Greens=(ID="green",T50=(R=232,G=245,B=233,A=255),T100=(R=200,G=230,B=201,A=255),T200=(R=165,G=214,B=167,A=255),T300=(R=129,G=199,B=132,A=255),T400=(R=102,G=187,B=106,A=255),T500=(R=76,G=175,B=80,A=255),T600=(R=67,G=160,B=71,A=255),T700=(R=56,G=142,B=60,A=255),T800=(R=46,G=125,B=50,A=255),T900=(R=27,G=94,B=32,A=255),A100=(R=185,G=246,B=202,A=255),A200=(R=105,G=240,B=174,A=255),A400=(R=0,G=230,B=118,A=255),A700=(R=0,G=200,B=83,A=255))
    LightGreens=(ID="lightgreen",T50=(R=241,G=248,B=233,A=255),T100=(R=220,G=237,B=200,A=255),T200=(R=197,G=225,B=165,A=255),T300=(R=174,G=213,B=129,A=255),T400=(R=156,G=204,B=101,A=255),T500=(R=139,G=195,B=74,A=255),T600=(R=124,G=179,B=66,A=255),T700=(R=104,G=159,B=56,A=255),T800=(R=85,G=139,B=47,A=255),T900=(R=51,G=105,B=30,A=255),A100=(R=204,G=255,B=144,A=255),A200=(R=178,G=255,B=89,A=255),A400=(R=118,G=255,B=3,A=255),A700=(R=100,G=221,B=23,A=255))
    Limes=(ID="lime",T50=(R=249,G=251,B=231,A=255),T100=(R=240,G=244,B=195,A=255),T200=(R=230,G=238,B=156,A=255),T300=(R=220,G=231,B=117,A=255),T400=(R=212,G=225,B=87,A=255),T500=(R=205,G=220,B=57,A=255),T600=(R=192,G=202,B=51,A=255),T700=(R=175,G=180,B=43,A=255),T800=(R=158,G=157,B=36,A=255),T900=(R=130,G=119,B=23,A=255),A100=(R=244,G=255,B=129,A=255),A200=(R=238,G=255,B=65,A=255),A400=(R=198,G=255,B=0,A=255),A700=(R=174,G=234,B=0,A=255))
    Yellows=(ID="yellow",T50=(R=255,G=253,B=231,A=255),T100=(R=255,G=249,B=196,A=255),T200=(R=255,G=245,B=157,A=255),T300=(R=255,G=241,B=118,A=255),T400=(R=255,G=238,B=88,A=255),T500=(R=255,G=235,B=59,A=255),T600=(R=253,G=216,B=53,A=255),T700=(R=251,G=192,B=45,A=255),T800=(R=249,G=168,B=37,A=255),T900=(R=245,G=127,B=23,A=255),A100=(R=255,G=255,B=141,A=255),A200=(R=255,G=255,B=0,A=255),A400=(R=255,G=234,B=0,A=255),A700=(R=255,G=214,B=0,A=255))
    Ambers=(ID="amber",T50=(R=255,G=248,B=225,A=255),T100=(R=255,G=236,B=179,A=255),T200=(R=255,G=224,B=130,A=255),T300=(R=255,G=213,B=79,A=255),T400=(R=255,G=202,B=40,A=255),T500=(R=255,G=193,B=7,A=255),T600=(R=255,G=179,B=0,A=255),T700=(R=255,G=160,B=0,A=255),T800=(R=255,G=143,B=0,A=255),T900=(R=255,G=111,B=0,A=255),A100=(R=255,G=229,B=127,A=255),A200=(R=255,G=215,B=64,A=255),A400=(R=255,G=196,B=0,A=255),A700=(R=255,G=171,B=0,A=255))
    Oranges=(ID="orange",T50=(R=255,G=243,B=224,A=255),T100=(R=255,G=224,B=178,A=255),T200=(R=255,G=204,B=128,A=255),T300=(R=255,G=183,B=77,A=255),T400=(R=255,G=167,B=38,A=255),T500=(R=255,G=152,B=0,A=255),T600=(R=251,G=140,B=0,A=255),T700=(R=245,G=124,B=0,A=255),T800=(R=239,G=108,B=0,A=255),T900=(R=230,G=81,B=0,A=255),A100=(R=255,G=209,B=128,A=255),A200=(R=255,G=171,B=64,A=255),A400=(R=255,G=145,B=0,A=255),A700=(R=255,G=109,B=0,A=255))   
    DeepOranges=(ID="deeporange",T50=(R=251,G=233,B=231,A=255),T100=(R=255,G=204,B=188,A=255),T200=(R=255,G=171,B=145,A=255),T300=(R=255,G=138,B=101,A=255),T400=(R=255,G=112,B=67,A=255),T500=(R=255,G=87,B=34,A=255),T600=(R=244,G=81,B=30,A=255),T700=(R=230,G=74,B=25,A=255),T800=(R=216,G=67,B=21,A=255),T900=(R=191,G=54,B=12,A=255),A100=(R=255,G=158,B=128,A=255),A200=(R=255,G=110,B=64,A=255),A400=(R=255,G=61,B=0,A=255),A700=(R=221,G=44,B=0,A=255))   
    Browns=(ID="brown",T50=(R=239,G=235,B=233,A=255),T100=(R=215,G=204,B=200,A=255),T200=(R=188,G=170,B=164,A=255),T300=(R=161,G=136,B=127,A=255),T400=(R=141,G=110,B=99,A=255),T500=(R=121,G=85,B=72,A=255),T600=(R=109,G=76,B=65,A=255),T700=(R=93,G=64,B=55,A=255),T800=(R=78,G=52,B=46,A=255),T900=(R=62,G=39,B=35,A=255))
    Greys=(ID="grey",T50=(R=250,G=250,B=250,A=255),T100=(R=245,G=245,B=245,A=255),T200=(R=238,G=238,B=238,A=255),T300=(R=224,G=224,B=224,A=255),T400=(R=189,G=189,B=189,A=255),T500=(R=158,G=158,B=158,A=255),T600=(R=117,G=117,B=117,A=255),T700=(R=97,G=97,B=97,A=255),T800=(R=66,G=66,B=66,A=255),T900=(R=33,G=33,B=33,A=255))
    BlueGreys=(ID="bluegrey",T50=(R=236,G=239,B=241,A=255),T100=(R=207,G=216,B=220,A=255),T200=(R=176,G=190,B=197,A=255),T300=(R=144,G=164,B=174,A=255),T400=(R=120,G=144,B=156,A=255),T500=(R=96,G=125,B=139,A=255),T600=(R=84,G=110,B=122,A=255),T700=(R=69,G=90,B=100,A=255),T800=(R=55,G=71,B=79,A=255),T900=(R=38,G=50,B=56,A=255))
}
