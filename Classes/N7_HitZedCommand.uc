class N7_HitZedCommand extends N7_Command;

enum ECmdArgs
{
    ARG_DAMAGETYPE,
    ARG_DAMAGE,
};

var protected const int MinLimit;
var protected config const int MaxLimit;
var protected config const int DefaultDamage;

var protected const Array<string> AvailableDamageTypes;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local Actor HitActor;
    local Vector HitNormal, HitLocation;
    local PlayerController Sender;
    local int ZedDamage;
    local string ZedDamageType;

    Sender = ExecState.GetSender();
    HitActor = Trace(
        HitLocation, 
        HitNormal, 
        Sender.ViewTarget.Location + 10000 * Vector(Sender.Rotation), 
        Sender.ViewTarget.Location,
        True
    );

    if (ExecState.GetArgC() > 0)
        ZedDamageType = Locs(ExecState.GetArg(ECmdArgs.ARG_DAMAGETYPE));
    else
        ZedDamageType = AvailableDamageTypes[0];
        

    if (ExecState.GetArgC() > 1) 
        ZedDamage = int(ExecState.GetArg(ECmdArgs.ARG_DAMAGE));
    else
        ZedDamage = DefaultDamage;

    if (Sender.Pawn != None && KFMonster(HitActor) != None)
    {
        DoDamage(ZedDamage, Pawn(HitActor), Sender.Pawn, vect(0, 0, 0), vect(0, 0, 0), ZedDamageType);
    }
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
    }

    Target.TakeDamage(Damage, InstigatedBy, HitLocation, Momentum, DamTypeClass);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int ZedDamage;
    local string ZedDamageType;

    if (ExecState.GetArgC() > 0)
    {
        ZedDamageType = Locs(ExecState.GetArg(ECmdArgs.ARG_DAMAGETYPE));

        if (
            ZedDamageType != AvailableDamageTypes[0] && 
            ZedDamageType != AvailableDamageTypes[1] && 
            ZedDamageType != AvailableDamageTypes[2])
        {
            return False;
        }
    }

    if (ExecState.GetArgC() > 1)
    {
        ZedDamage = int(ExecState.GetArg(ECmdArgs.ARG_DAMAGE));

        if (!IsInRange(ZedDamage, MinLimit, MaxLimit))
        {
            return False;
        }
    }

    return True;
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "You must provide valid DamageType and Damage value between "$MinLimit$" and "$MaxLimit;
}

defaultproperties
{
    Aliases(0)="HITZ"
    AvailableDamageTypes(0)="hit"
    AvailableDamageTypes(1)="frag"
    AvailableDamageTypes(2)="fire"
    MinLimit=0
    MaxLimit=100000
    DefaultDamage=10000
    MinArgsNum=0
    MaxArgsNum=2
    ArgTypes(0)="word"
    ArgTypes(1)="number"
    Signature="<? string DamageType, ? int Damage>"
    Description="Damage Zed being looked at. Available Damage types: hit, frag, fire"
    bOnlyAliveSender=True
    bNotifySenderOnSuccess=False
}
