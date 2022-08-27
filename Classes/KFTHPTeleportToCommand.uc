class KFTHPTeleportToCommand extends KFTHPUnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    local Vector TpLocation;

    TpLocation = PC.Pawn.Location;
    ExecState.GetSender().ViewTarget.SetLocation(TpLocation + 72 * Vector(ExecState.GetSender().Rotation) + vect(0, 0, 1) * 15);
    ExecState.GetSender().ViewTarget.PlayTeleportEffect(false, true);
}

/** @Override */
protected function bool CheckGameState(KFTHPCommandExecutionState ExecState)
{
    if (KFGT.IsInState('MatchInProgress'))
    {
        return true;
    }

    return false;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "You can teleport only during the game";
}

/** @Override */
protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return "Cannot find alive player with name "$LoadTarget(ExecState);
}

defaultproperties
{
    bAdminOnly=true
    Aliases(0)="TPT"
    Aliases(1)="TELEPORTP"
    ArgTypes(0)="any"
    Signature="<string TargetName>"
    Description="Teleport to another player"
    bOnlyAliveTargets=true
    bNotifySenderOnSuccess=false
}
