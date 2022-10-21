class N7_RestoreAttrsCommand extends N7_BinaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    switch (ExecState.GetArgC())
    {
        case 0:
            GSU.RestorePlayerAttributes(PC);
            break;

        case 1:
        case 2:
            if (IsSwitchOnValue(ExecState.GetArg(ECmdArgs.ARG_VALUE)))
            {
                AddRestoredPlayer(PC);
                ExecState.SaveFlag(True);
            }
            else
            {
                RemoveRestoredPlayer(PC);
                ExecState.SaveFlag(False);
            }
            break;
    }
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return ExecState.GetArgC() > 0 
        || ExecState.GetArgC() == 0 && !KFGT.IsInState('PendingMatch') && KFGT.WaveCountDown > 0;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Attributes can be restored only during trade time";
}

/** @Override */
protected function string InvalidTargetMessage(N7_CommandExecutionState ExecState)
{
    return "Cannot restore attributes of dead players";
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = ExecState.LoadTarget();

    switch (ExecState.GetArgC())
    {
        case 0:
            return "Your attributes have been restored";

        case 1:
        case 2:
            if (TargetName ~= "all")
            {
                return "Attribute restoration is "$ColorizeValue(ExecState.LoadEnabled())$" for all players";
            }

            return "Attribute restoration is "$ColorizeValue(ExecState.LoadEnabled());
    }
}

/** @Override */
protected function ExtendedHelp(PlayerController PC)
{
    HelpSectionSeparator(PC, "Call Options");
    SendMessage(PC, "No arguments - Instant own attribute restoration");
    SendMessage(PC, "One argument - Toggle own attribute restoration before and after each wave");
    SendMessage(PC, "Two arguments - Toggle attribute restoration before and after each wave for other players");
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=2
    Aliases(0)="AR"
    ArgTypes(0)="switch"
    ArgTypes(1)="any"
    Signature="<? (0 | 1 | ON | OFF), ? (string TargetName | 'all')>"
    Description="Restore HP/Armor/Ammo"
}
