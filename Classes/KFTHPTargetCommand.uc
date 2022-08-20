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

protected function bool DoesTargetExist(string TargetName, out string TargetFullName)
{
    local Controller C;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (IsPlayer(C) && IsStringPartOf(TargetName, PlayerController(C).PlayerReplicationInfo.PlayerName))
        {
            TargetFullName = PlayerController(C).PlayerReplicationInfo.PlayerName;

            return true;            
        }
    }
    return false;
}

defaultproperties
{
    bUseTargets=true
    bNotifySenderOnSuccess=false
    bNotifyTargetsOnSuccess=true
}
