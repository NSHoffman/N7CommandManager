/**
 * This class provides general abstraction for commands
 * whose purpose is to change some game settings
 */
class N7_GameSettingsCommand extends N7_Command
    abstract;

defaultproperties
{
    bNotifySenderOnSuccess=false
    bNotifyGlobalOnSuccess=true
    CommandStateClass=class'N7_CommandPreservedState'
}
