class N7_CommandMessageColors extends Core.Object
    config(N7CommandManager);

var protected const class<N7_ColorManager> ColorManager;

enum EColorTypes
{
    CT_None,
    CT_Main,
    CT_Sender,
    CT_Target,
    CT_Entity,
    CT_Value,
    CT_Signature,
    CT_Emphasis,
    CT_Error,
};

var public config const string Main;
var public config const string Sender;
var public config const string Target;
var public config const string Entity;
var public config const string Value;
var public config const string Signature;
var public config const string Emphasis;
var public config const string Error;

/****************************
 *  PUBLIC INTERFACE
 ****************************/

public final function string ColorizeMain(
    string Text, bool bDisableColoring)
{
    return Colorize(Text, EColorTypes.CT_Main, bDisableColoring, True);
}

public final function string ColorizeSender(
    string SenderName, bool bDisableColoring)
{
    return Colorize(SenderName, EColorTypes.CT_Sender, bDisableColoring);
}

public final function string ColorizeTarget(
    string TargetName, bool bDisableColoring)
{
    return Colorize(TargetName, EColorTypes.CT_Target, bDisableColoring);
}

public final function string ColorizeEntity(
    string EntityName, bool bDisableColoring)
{
    return Colorize(EntityName, EColorTypes.CT_Entity, bDisableColoring);
}

public final function string ColorizeValue(
    string Value, bool bDisableColoring)
{
    return Colorize(Value, EColorTypes.CT_Value, bDisableColoring);
}

public final function string ColorizeSignature(
    string Signature, bool bDisableColoring)
{
    return Colorize(Signature, EColorTypes.CT_Signature, bDisableColoring);
}

public final function string ColorizeEmphasis(
    string Text, bool bDisableColoring)
{
    return Colorize(Text, EColorTypes.CT_Emphasis, bDisableColoring);
}

public final function string ColorizeError(
    string Text, bool bDisableColoring)
{
    return Colorize(Text, EColorTypes.CT_Error, bDisableColoring);
}

/****************************
 *  IMPLEMENTATION
 ****************************/

protected final function string Colorize(
    string Text, int Type, bool bDisableColoring, optional bool bSkipColorRestore)
{
    local string ColorID;    
    ColorID = SelectColorID(Type);

    if (bDisableColoring)
        return Text;

    return ColorManager.static.TextRGBA(
        Text, ColorManager.static.GetColor(ColorID), bSkipColorRestore
    );
}

protected final function string SelectColorID(int Type)
{
    switch (Type)
    {
        case EColorTypes.CT_Sender:     return Sender;
        case EColorTypes.CT_Target:     return Target;
        case EColorTypes.CT_Entity:     return Entity;
        case EColorTypes.CT_Value:      return Value;
        case EColorTypes.CT_Signature:  return Signature;
        case EColorTypes.CT_Emphasis:   return Emphasis;
        case EColorTypes.CT_Error:      return Error;

        default:                        return Main;
    }
}

defaultproperties
{
    ColorManager=class'N7_ColorManager'

    Main="white"
    Signature="white"
    Sender="white"
    Target="white"
    Entity="white"
    Value="white"
    Emphasis="white"
    Error="white"
}
