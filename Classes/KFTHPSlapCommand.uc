class KFTHPSlapCommand extends KFTHPUnaryTargetCommand;

var protected config const int SlapDamage;
var protected config const int SlapDamageForce;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    local Pawn InstigatedBy;
    local Vector HitLocation, PushDirection;
    local int TotalDamage;

    InstigatedBy = ExecState.GetSender().Instigator;
    PushDirection = SlapDamageForce * Normal(VRand());

    if (PC.Pawn.Health - SlapDamage >= 1)
        TotalDamage = SlapDamage;
    else
        TotalDamage = PC.Pawn.Health - 1;

    PC.Pawn.TakeDamage(
        TotalDamage, InstigatedBy, HitLocation, PushDirection, class'Engine.DamageType');
}

/** @Override */
protected function bool CheckGameState(KFTHPCommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Players can be slapped only during the game";
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "You have been slapped by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players have been slapped by "$GetInstigatorName(ExecState);
    }

    return TargetName$" has been slapped by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    bAdminOnly=true
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="SLAP"
    ArgTypes(0)="any"
    Signature="<? string TargetName>"
    Description="Slap Player"
    SlapDamage=5
    SlapDamageForce=150000
    bOnlyAliveTargets=true
    bNotifyGlobalOnSuccess=true
}
