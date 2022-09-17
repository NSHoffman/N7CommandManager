class N7_TeleportToCommand extends N7_UnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    local Vector TpLocation;

    TpLocation = PC.Pawn.Location;
    ExecState.GetSender().ViewTarget.SetLocation(TpLocation + 72 * Vector(ExecState.GetSender().Rotation) + vect(0, 0, 1) * 15);
    ExecState.GetSender().ViewTarget.PlayTeleportEffect(False, True);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
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
    bAdminOnly=True
    Aliases(0)="TPP"
    Aliases(1)="TELEPORTP"
    ArgTypes(0)="any"
    Signature="<? string TargetName>"
    Description="Teleport to another player"
    bOnlyAliveTargets=True
    bNotifySenderOnSuccess=False
}
