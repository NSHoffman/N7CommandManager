/**
 * This class provides general abstraction for commands
 * whose purpose is to change some game settings
 */
class KFTHPGameSettingsCommand extends KFTHPCommand
    abstract;

defaultproperties
{
    bNotifySenderOnSuccess=false
    bNotifyGlobalOnSuccess=true
    CommandStateClass=class'KFTHPCommandPreservedState'
}
