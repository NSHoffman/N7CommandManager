class N7_CommandValidator extends Core.Object;

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

public function bool IsEmptyString(string Str)
{
    return Str == "";
}

public function int GetMaxAcceptableStringLength()
{
    return default.MaxAcceptableStringLength;
}

public function float GetStringMatchRatio(string SubStr, string SupStr)
{
    local int MatchSubstrStartIdx;

    MatchSubstrStartIdx = InStr(Caps(SupStr), Caps(SubStr));

    if (MatchSubstrStartIdx < 0)
    {
        return 0;
    }

    return (1 - Min(MatchSubstrStartIdx, 1) * 0.01) * (float(Len(SubStr)) / float(Len(SupStr)));
}

public function bool IsValidLengthString(string Str)
{
    return Len(Str) <= default.MaxAcceptableStringLength;
}

public function bool IsStringPartOf(string SubStr, string SupStr)
{
    return InStr(Caps(SupStr), Caps(SubStr)) >= 0;
}

public function bool IsLetter(string Str)
{
    local string Ch;
    Ch = Mid(Str, 0, 1);

    return IsInRange(Asc(Ch), default.MinUppercaseLetterCode, default.MaxUppercaseLetterCode)
        || IsInRange(Asc(Ch), default.MinLowercaseLetterCode, default.MaxLowercaseLetterCode);
}

public function bool IsWord(string Str)
{
    local int i;

    for (i = 0; i < Len(Str); i++)
    {
        if (!IsLetter(Mid(Str, i, 1)))
        {
            return False;
        }
    }

    return True;
}

public function bool IsDigit(string Str)
{
    local string Ch;
    Ch = Mid(Str, 0, 1);

    return IsInRange(Asc(Ch), default.MinDigitCode, default.MaxDigitCode);
}

public function bool IsNumber(string Str)
{
    local int i;
    local string Ch;
    local bool bFloatingPointFound, bValidMinus;

    for (i = 0; i < Len(Str); i++)
    {
        Ch = Mid(Str, i, 1);

        bValidMinus = Asc(Ch) == CHR_MINUS && i == 0;

        if (Asc(Ch) == CHR_DOT)
        {
            if (!bFloatingPointFound)
            {
                bFloatingPointFound = True;
            }
            else
            {
                return False;
            }
        }
        else if (!IsDigit(Ch) && !bValidMinus)
        {
            return False;
        }
    }

    return True;
}

public function bool IsSwitchOnValue(string Value)
{
    return Value ~= "ON" || Value ~= "1";
}

public function bool IsSwitchOffValue(string Value)
{
    return Value ~= "OFF" || Value ~= "0";
}

public function bool IsSwitchValue(string Value)
{
    return IsSwitchOnValue(Value) || IsSwitchOffValue(Value);
}

/*********************************
 * NUMBER VALIDATION
 *********************************/

public function bool IsInRange(
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

public function bool IsInRangeF(
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

public function bool IsPlayer(Controller C)
{
    return PlayerController(C) != None;
}

public function bool IsSpectator(PlayerController PC)
{
    return PC.PlayerReplicationInfo.bOnlySpectator;
}

public function bool IsAlive(PlayerController PC)
{
    return !PC.PlayerReplicationInfo.bIsSpectator 
        && !PC.PlayerReplicationInfo.bOutOfLives 
        && PC.Pawn != None 
        && PC.Pawn.Health > 0;
}

/** 
 * Original admin access implies that EITHER bAdmin OR bSilentAdmin is True depending on how user logs in 
 * Temporary admin access requires BOTH flags to be True so that these access types can be differentiated
 */
public function bool IsAdmin(PlayerController PC)
{
    return PC.PlayerReplicationInfo.bAdmin ^^ PC.PlayerReplicationInfo.bSilentAdmin;
}

public function bool IsTempAdmin(PlayerController PC)
{
    return PC.PlayerReplicationInfo.bAdmin && PC.PlayerReplicationInfo.bSilentAdmin;
}

public function bool HasAdminAccess(PlayerController PC)
{
    return IsAdmin(PC) || IsTempAdmin(PC);
}

public function bool IsWebAdmin(PlayerController PC)
{
    return PC.PlayerReplicationInfo.PlayerName == "WebAdmin";
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
