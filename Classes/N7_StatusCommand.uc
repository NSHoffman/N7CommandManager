class N7_StatusCommand extends N7_UnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    ExecState.SaveFlag(IsZedTimeEnabled());

    SendMessage(PC, "MZ - "$KFGT.MaxZombiesOnce$" | "$"SR - "$KFGT.KFLRules.WaveSpawnPeriod$" | "$"HP - "$GetZedHPConfig());
    SendMessage(PC, "SLOTS - "$KFGT.MaxPlayers$" | "$"SPECS - "$KFGT.MaxSpectators$" | "$"FAKES - "$GetFakedPlayersNum());
    SendMessage(PC, "ZT - "$ExecState.LoadSwitch(True)$" | "$"GS - "$KFGT.GameSpeed);
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    return ExecState.GetArgC() == 0 || ExecState.GetArgC() == 1 && ExecState.GetArg(ECmdArgs.ARG_TARGETNAME) ~= "all";
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Command only accepts 'all' as an argument";
}

/** @Override */
protected function ExtendedHelp(PlayerController PC)
{
    HelpSectionSeparator(PC, "Zeds Related Settings");
    SendMessage(PC, "MZ - Max Zeds at once");
    SendMessage(PC, "SR - Zeds Spawn Rate");
    SendMessage(PC, "HP - Zeds HP Config");
    SendMessage(PC, "ZT - Zed Time Enabled");
    SendMessage(PC, "GS - Game Speed");

    HelpSectionSeparator(PC, "Players Related Settings");
    SendMessage(PC, "SLOTS - Max Players");
    SendMessage(PC, "SPECS - Max Spectators");
    SendMessage(PC, "FAKES - Faked Players Number");
}

defaultproperties
{
    ArgTypes(0)="word"

    Aliases(0)="STATUS"
    Description="Display current game settings. 'all' allows for broadcasting status to all players"
    Signature="<? 'all'>"

    bNotifyTargetsOnSuccess=False

    bOnlyPlayerTargets=False

    bOnlyPlayerSender=False
}
