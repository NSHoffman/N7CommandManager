class N7_StatusCommand extends N7_Command;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    SendMessage(ExecState.GetSender(), "MZ - "$KFGT.MaxZombiesOnce$" | "$"FAKES - "$FakedPlayersNum$" | "$"HP - "$GSU.GetFinalZedHPConfig()$" | "$"SR - "$KFGT.KFLRules.WaveSpawnPeriod);
    SendMessage(ExecState.GetSender(), "SLOTS - "$KFGT.MaxPlayers$" | "$"SPECS - "$KFGT.MaxSpectators);
    
    if (IsZedTimeDisabled())
    {
        SendMessage(ExecState.GetSender(), "ZED-Time is disabled");
    }
    else
    {
        SendMessage(ExecState.GetSender(), "ZED-Time is enabled");
    }
}

defaultproperties
{
    Aliases(0)="STATUS"
    Signature="<>"
    Description="Display current game settings"
    bNotifySenderOnSuccess=False
    bOnlyPlayerSender=False
}
