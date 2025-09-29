class N7_SlapCommand extends N7_UnaryTargetCommand;

var protected config const int SlapDamage;
var protected config const int SlapDamageForce;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    local Pawn InstigatedBy;
    local Vector HitLocation, PushDirection;
    local int TotalDamage;

    InstigatedBy = ExecState.GetSender().Instigator;
    PushDirection = SlapDamageForce * Normal(VRand());

    if (PC.Pawn.Health - SlapDamage >= 1)
    {
        TotalDamage = SlapDamage;
    }
    else
    {
        TotalDamage = PC.Pawn.Health - 1;
    }

    PC.Pawn.TakeDamage(TotalDamage, InstigatedBy, HitLocation, PushDirection, class'Engine.DamageType');
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return !KFGT.IsInState('PendingMatch');
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Players can be slapped only during the game";
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "You have been slapped by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;

    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players have been slapped by "$ColorizeSender(ExecState);
    }

    return ColorizeTarget(TargetName)$" has been slapped by "$ColorizeSender(ExecState);
}

defaultproperties
{
    SlapDamage=5
    SlapDamageForce=150000

    Aliases(0)="SLAP"
    Description="Slap player"
    Signature="<? string TargetName>"

    bNotifyGlobalOnSuccess=True

    bOnlyAliveTargets=True

    bAdminOnly=True
}
