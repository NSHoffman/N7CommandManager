class N7_ReadyAllCommand extends N7_UnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    PC.PlayerReplicationInfo.bReadyToPlay = true;
}

/** @Override */
protected function bool ShouldBeTarget(
    N7_CommandExecutionState ExecState, 
    PlayerController PC)
{
    return AcceptTargetByName(ExecState, PC, "all");
}

/** @Override */
protected function bool CheckTargets(N7_CommandExecutionState ExecState)
{
    return true;
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('PendingMatch');
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Game is already started";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Game forcibly started by "$ColorizeSender(ExecState);
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=0
    Aliases(0)="AS"
    Aliases(1)="AUTOSTART"
    Aliases(2)="RALL"
    Aliases(3)="READYALL"
    Signature="<>"
    Description="Force ready upon all players"
    bNotifyTargetsOnSuccess=false
    bNotifyGlobalOnSuccess=true
}
