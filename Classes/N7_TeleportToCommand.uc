class N7_TeleportToCommand extends N7_BinaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    local string TeleportTargetName;
    local Vector TpLocation;

    TeleportTargetName = ExecState.LoadString();
    TpLocation = FindTarget(TeleportTargetName).Pawn.Location;

    PC.ViewTarget.SetLocation(TpLocation + 72 * Vector(PC.Rotation) + vect(0, 0, 1) * 15);
    PC.ViewTarget.PlayTeleportEffect(False, True);
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local string TeleportTargetName;
    local bool bValidTeleportTarget;

    TeleportTargetName = ExecState.GetArg(ECmdArgs.ARG_VALUE);
    bValidTeleportTarget = VerifyTargetByName(ExecState, TeleportTargetName);
    ExecState.SaveString(TeleportTargetName);

    return bValidTeleportTarget;
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Invalid teleport target "$ColorizeTarget(ExecState.LoadString());
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
    ArgTypes(1)="any"
    MinArgsNum=1
    Signature="<string TeleportTo, ? string TargetName>"
    Description="Teleport a player to another player"
    bAllowTargetAll=False
    bOnlyAliveTargets=True
    bOnlyAliveSender=True
    bNotifySenderOnSuccess=False
    bNotifyTargetsOnSuccess=False
}
