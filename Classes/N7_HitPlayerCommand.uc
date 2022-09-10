class N7_HitPlayerCommand extends N7_UnaryTargetCommand;

enum ECmdArgs_X
{
    ARG_TARGETNAME,
    ARG_DAMAGETYPE,
    ARG_DAMAGE,
};

var protected const int MinDamage;
var protected config const int MaxDamage;
var protected config const int DefaultDamage;

var protected editconstarray Array<string> AvailableDamageTypes;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    local int PlayerDamage;
    local string PlayerDamageType;
    local Pawn InstigatedBy;

    InstigatedBy = ExecState.GetSender().Instigator;

    if (ExecState.GetArgC() > 1)
        PlayerDamageType = Locs(ExecState.GetArg(ECmdArgs_X.ARG_DAMAGETYPE));
    else
        PlayerDamageType = AvailableDamageTypes[0];

    if (ExecState.GetArgC() > 2) 
        PlayerDamage = ToInt(ExecState.GetArg(ECmdArgs_X.ARG_DAMAGE));
    else
        PlayerDamage = DefaultDamage;

    DoDamage(PlayerDamage, PC.Pawn, InstigatedBy, vect(0, 0, 0), vect(0, 0, 0), PlayerDamageType);
}

protected function DoDamage(
    int Damage, Pawn Target, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, string DamageType)
{
    local class<DamageType> DamTypeClass;

    switch (DamageType)
    {
        case AvailableDamageTypes[0]: 
            DamTypeClass = class'Engine.DamageType';
            break;

        case AvailableDamageTypes[1]:
            DamTypeClass = class'KFMod.DamTypeFrag';
            InstigatedBy.Spawn(
                class<Actor>(DynamicLoadObject("KFMod.KFNadeLExplosion", class'Class')),,,
                Target.Location + 72 * Vector(InstigatedBy.Rotation) + vect(0, 0, 1) * 15
            );
            break;
    
        case AvailableDamageTypes[2]: 
            DamTypeClass = class'KFMod.DamTypeBurned';
            break;

        case AvailableDamageTypes[3]: 
            DamTypeClass = class'KFMod.DamTypeVomit';
            break;
    }

    Target.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamTypeClass);
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int PlayerDamage;
    local string PlayerDamageType;

    if (ExecState.GetArgC() > 1)
    {
        PlayerDamageType = Locs(ExecState.GetArg(ECmdArgs_X.ARG_DAMAGETYPE));

        if (
            PlayerDamageType != AvailableDamageTypes[0] && 
            PlayerDamageType != AvailableDamageTypes[1] && 
            PlayerDamageType != AvailableDamageTypes[2] &&
            PlayerDamageType != AvailableDamageTypes[3])
        {
            return false;
        }
    }

    if (ExecState.GetArgC() > 2)
    {
        PlayerDamage = ToInt(ExecState.GetArg(ECmdArgs_X.ARG_DAMAGE));

        if (!IsInRange(PlayerDamage, MinDamage, MaxDamage))
        {
            return false;
        }
    }

    return true;
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "You must provide valid DamageType and Damage value between "$MinDamage$" and "$MaxDamage;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Players can be hit only during the game";
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "You have been hit by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players have been hit by "$GetInstigatorName(ExecState);
    }

    return TargetName$" has been hit by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    bAdminOnly=true
    MinArgsNum=0
    MaxArgsNum=3
    Aliases(0)="HITP"
    ArgTypes(0)="any"
    ArgTypes(1)="word"
    ArgTypes(2)="number"
    MinDamage=0
    MaxDamage=10000
    DefaultDamage=10
    AvailableDamageTypes(0)="hit"
    AvailableDamageTypes(1)="frag"
    AvailableDamageTypes(2)="fire"
    AvailableDamageTypes(3)="vomit"
    Signature="<? string TargetName, ? string DamageType, ? int Damage>"
    Description="Damage Player. Available Damage types: hit, frag, fire, vomit"
    bOnlyAliveTargets=true
    bNotifyGlobalOnSuccess=true
}
