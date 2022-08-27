/**
 * This class provides general abstraction for commands
 * whose purpose is to change some game settings
 */
class KFTHPGameSettingsCommand extends KFTHPCommand
    abstract;

/** Will return the instigator of the setting change */
protected function string GetInstigatorName(KFTHPCommandExecutionState ExecState)
{
    return ExecState.GetSender().PlayerReplicationInfo.PlayerName;
}

defaultproperties
{
    bNotifySenderOnSuccess=false
    bNotifyGlobalOnSuccess=true
    CommandStateClass=Class'KFTHPCommandPreservingState'
}
