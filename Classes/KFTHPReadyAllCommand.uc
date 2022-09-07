class KFTHPReadyAllCommand extends KFTHPUnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    PC.PlayerReplicationInfo.bReadyToPlay = true;
}

/** @Override */
protected function bool ShouldBeTarget(
    KFTHPCommandExecutionState ExecState, 
    PlayerController PC)
{
    return AcceptTargetByName(ExecState, PC, "all");
}

/** @Override */
protected function bool CheckTargets(KFTHPCommandExecutionState ExecState)
{
    return true;
}

/** @Override */
protected function bool CheckGameState(KFTHPCommandExecutionState ExecState)
{
    return KFGT.IsInState('PendingMatch');
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Game is already started";
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "Game forcibly started by "$GetInstigatorName(ExecState);
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
