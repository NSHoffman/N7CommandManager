class KFTHPCommandValidator extends Core.Object;

const CHR_MINUS = 45;
const CHR_DOT = 46;

var protected const int MinDigitCode;
var protected const int MaxDigitCode;
var protected const int MinUppercaseLetterCode;
var protected const int MaxUppercaseLetterCode;
var protected const int MinLowercaseLetterCode;
var protected const int MaxLowercaseLetterCode;
var protected const int MaxAcceptableStringLength;

/*********************************
 * STRING VALIDATION
 *********************************/

static function bool IsEmptyString(string Str)
{
    return Str == "";
}

static function int GetMaxAcceptableStringLength()
{
    return default.MaxAcceptableStringLength;
}

static function bool IsValidLengthString(string Str)
{
    return Len(Str) <= default.MaxAcceptableStringLength;
}

static function bool IsStringPartOf(string SubStr, string SupStr)
{
    return InStr(Caps(SupStr), Caps(SubStr)) >= 0;
}

static function bool IsLetter(string Str)
{
    local string Ch;
    Ch = Mid(Str, 0, 1);

    return IsInRange(Asc(Ch), default.MinUppercaseLetterCode, default.MaxUppercaseLetterCode)
        || IsInRange(Asc(Ch), default.MinLowercaseLetterCode, default.MaxLowercaseLetterCode);
}

static function bool IsWord(string Str)
{
    local int i;

    for (i = 0; i < Len(Str); i++)
    {
        if (!IsLetter(Mid(Str, i, 1)))
        {
            return false;
        }
    }

    return true;
}

static function bool IsDigit(string Str)
{
    local string Ch;
    Ch = Mid(Str, 0, 1);

    return IsInRange(Asc(Ch), default.MinDigitCode, default.MaxDigitCode);
}

static function bool IsNumber(string Str)
{
    local int i;
    local string Ch;
    local bool bFloatingPointFound;

    for (i = 0; i < Len(Str); i++)
    {
        Ch = Mid(Str, i, 1);

        if (Asc(Ch) == CHR_DOT && !bFloatingPointFound)
        {
            bFloatingPointFound = true;
            continue;
        }
        else if (Asc(Ch) == CHR_DOT)
        {
            return false;
        }

        if (Asc(Ch) == CHR_MINUS && i == 0 && Len(Str) > 0)
        {
            return false;
        }

        if (!IsDigit(Ch))
        {
            return false;
        }
    }

    return true;
}

static function bool IsSwitchOnValue(string Value)
{
    return Value ~= "ON" || Value ~= "1";
}

static function bool IsSwitchOffValue(string Value)
{
    return Value ~= "OFF" || Value ~= "0";
}

static function bool IsSwitchValue(string Value)
{
    return IsSwitchOnValue(Value) || IsSwitchOffValue(Value);
}

/*********************************
 * NUMBER VALIDATION
 *********************************/

static function bool IsInRange(
    coerce int Number, 
    int Start, 
    optional int End)
{
    if (End > 0)
    {
        return Number >= Start && Number <= End;
    }

    return Number >= Start;
}

static function bool IsInRangeF(
    coerce float Number, 
    float Start, 
    optional float End)
{
    if (End > 0)
    {
        return Number >= Start && Number <= End;
    }

    return Number >= Start;
}

/*********************************
 * GAME OBJECTS VALIDATION
 *********************************/

static function bool IsPlayer(Controller C)
{
    return C.IsA('PlayerController') || C.IsA('xBot');
}

static function bool IsAlive(PlayerController PC)
{
    return PC.Pawn.Health > 0;
}

defaultproperties
{
    MinDigitCode=48
    MaxDigitCode=57
    MinUppercaseLetterCode=65
    MaxUppercaseLetterCode=90
    MinLowercaseLetterCode=97
    MaxLowercaseLetterCode=122
    MaxAcceptableStringLength=25
}
