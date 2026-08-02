class N7_HitZedCommand extends N7_Command;

enum ECmdArgs
{
    ARG_DAMAGETYPE,
    ARG_DAMAGE,
};

var protected const int MinLimit;
var protected config const int MaxLimit;
var protected config const int DefaultDamage;
var protected config float MaxRange;

var protected const Array<string> AvailableDamageTypes;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local Actor HitActor;
    local Vector HitNormal, HitLocation, EndTrace, CamLoc;
    local PlayerController Sender;
    local KFMonster KFM;
    local int ZedDamage;
    local string ZedDamageType;

    Sender = ExecState.GetSender();

    if (Sender.Pawn != None)
    {
        CamLoc = Sender.Pawn.Location + Sender.Pawn.EyePosition();
        EndTrace = CamLoc + MaxRange * Vector(Sender.Rotation);
        HitActor = Sender.Pawn.Trace(HitLocation, HitNormal, EndTrace, CamLoc, True);
    }
    else
    {
        CamLoc = Sender.Location;
        EndTrace = CamLoc + MaxRange * Vector(Sender.Rotation);
        HitActor = Sender.Trace(HitLocation, HitNormal, EndTrace, CamLoc, True);
    }

    KFM = GetMonster(HitActor);

    if (ExecState.GetArgC() > 0)
    {
        ZedDamageType = Locs(ExecState.GetArg(ECmdArgs.ARG_DAMAGETYPE));
    }
    else
    {
        ZedDamageType = AvailableDamageTypes[0];
    }

    if (ExecState.GetArgC() > 1) 
    {
        ZedDamage = int(ExecState.GetArg(ECmdArgs.ARG_DAMAGE));
    }
    else
    {
        ZedDamage = DefaultDamage;
    }

    if (KFM != None)
    {
        DoDamage(ZedDamage, KFM, Sender.Pawn, HitLocation, Vector(Sender.Rotation) * ZedDamage, ZedDamageType);
    }
}

protected function KFMonster GetMonster(Actor HitActor)
{
    local KFMonster KFM;

    if (HitActor == None)
    {
        return None;
    }

    KFM = KFMonster(HitActor);

    if (KFM != None)
    {
        return KFM;
    }

    if (HitActor.IsA('ExtendedZCollision'))
    {
        KFM = KFMonster(HitActor.Owner);

        if (KFM != None)
        {
            return KFM;
        }
    }

    return None;
}

protected function DoDamage(int Damage, Pawn Target, Pawn InstigatedBy, Vector HitLocation, Vector Momentum, string DamageType)
{
    local class<DamageType> DamTypeClass;

    switch (DamageType)
    {
        case AvailableDamageTypes[0]: 
            DamTypeClass = class'Engine.DamageType';
            break;

        case AvailableDamageTypes[1]:
            DamTypeClass = class'KFMod.DamTypeFrag';
            InstigatedBy.Spawn(class<Actor>(DynamicLoadObject("KFMod.KFNadeLExplosion", class'Class')),,, HitLocation);
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

protected function ExtendedHelp(PlayerController PC)
{
    local int i;
    HelpSectionSeparator(PC, "Available Damage Types");

    for (i = 0; i < AvailableDamageTypes.Length; i++)
    {
        SendMessage(PC, AvailableDamageTypes[i]);
    }
}

defaultproperties
{
    MaxArgsNum=2
    ArgTypes(0)="word"
    ArgTypes(1)="number"

    MaxRange=10000
    MaxLimit=100000
    DefaultDamage=10000

    AvailableDamageTypes(0)="hit"
    AvailableDamageTypes(1)="frag"
    AvailableDamageTypes(2)="fire"

    Aliases(0)="HITZ"
    Description="Damage ZED being looked at"
    Signature="<? string DamageType, ? int Damage>"

    bNotifySenderOnSuccess=False

    bOnlyPlayerSender=False
    bOnlyAliveSender=False

    bAdminOnly=True
}
