/**
 * This state has extended functionality in terms that it can
 * preserve some pieces of intermediary state for later use
 * so that there is no need to recalculate same parts again
 */
class KFTHPCommandPreservedState extends KFTHPCommandExecutionState;

var protected string PreservedString;
var protected string PreservedTarget;

var protected int PreservedNumber;
var protected int PreservedMinLimit;
var protected int PreservedMaxLimit;

var protected float PreservedNumberF;
var protected float PreservedMinLimitF;
var protected float PreservedMaxLimitF;

var protected bool bPreservedFlag;

public final function SaveString(string Value)
{
    PreservedString = Value;
}

public final function SaveTarget(string Value)
{
    PreservedTarget = Value;
}

public final function SaveNumber(int Value)
{
    PreservedNumber = Value;
}

public final function SaveMinLimit(int Value)
{
    PreservedMinLimit = Value;
}

public final function SaveMaxLimit(int Value)
{
    PreservedMaxLimit = Value;
}

public final function SaveNumberF(float Value)
{
    PreservedNumberF = Value;
}

public final function SaveMinLimitF(float Value)
{
    PreservedMinLimitF = Value;
}

public final function SaveMaxLimitF(float Value)
{
    PreservedMaxLimitF = Value;
}

public final function SaveFlag(bool bValue)
{
    bPreservedFlag = bValue;
}

public final function string LoadString()
{
    return PreservedString;
}

public final function string LoadTarget()
{
    return PreservedTarget;
}

public final function int LoadNumber()
{
    return PreservedNumber;
}

public final function int LoadMinLimit()
{
    return PreservedMinLimit;
}

public final function int LoadMaxLimit()
{
    return PreservedMaxLimit;
}

public final function float LoadNumberF()
{
    return PreservedNumberF;
}

public final function float LoadMinLimitF()
{
    return PreservedMinLimitF;
}

public final function float LoadMaxLimitF()
{
    return PreservedMaxLimitF;
}

public final function bool LoadFlag()
{
    return bPreservedFlag;
}

public final function string LoadSwitch(optional bool bAllCaps)
{
    if (bPreservedFlag)
    {
        return EnsureUpperCase("On", bAllCaps);
    }
    
    return EnsureUpperCase("Off", bAllCaps);
}

public final function string LoadEnabled(optional bool bAllCaps)
{
    if (bPreservedFlag)
    {
        return EnsureUpperCase("enabled", bAllCaps);
    }
    
    return EnsureUpperCase("disabled", bAllCaps);
}

protected final function string EnsureUpperCase(string Value, bool bAllCaps)
{
    if (bAllCaps)
    {
        return Caps(Value);
    }

    return Value;
}

defaultproperties
{}
