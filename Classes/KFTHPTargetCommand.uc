/**
 * This class provides common logic for commands
 * that are supposed to affect a selection of players
 */
class KFTHPTargetCommand extends KFTHPCommand
    abstract;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local int i;

    for (i = 0; i < ExecState.GetTargetsNum(); i++)
    {
        DoActionForSingleTarget(ExecState, ExecState.GetTarget(i));
    }
}

/** @Override */
protected function bool ShouldBeTarget(
    KFTHPCommandExecutionState ExecState, 
    PlayerController PC)
{
    return true;
}

protected function PlayerController FindTarget(string TargetName)
{
    local Controller C;
    local PlayerController PC;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        PC = PlayerController(C);

        if (IsPlayer(PC) && IsStringPartOf(TargetName, PC.PlayerReplicationInfo.PlayerName))
        {
            return PC;   
        }
    }
    return None;
}

defaultproperties
{
    bUseTargets=true
    bNotifySenderOnSuccess=false
    bNotifyTargetsOnSuccess=true
}
