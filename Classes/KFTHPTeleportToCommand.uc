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
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "You can teleport only during the game";
}

defaultproperties
{
    bAdminOnly=true
    Aliases(0)="TPP"
    Aliases(1)="TELEPORTP"
    ArgTypes(0)="any"
    Signature="<? string TargetName>"
    Description="Teleport to another player"
    bOnlyAliveTargets=true
    bNotifySenderOnSuccess=false
}
