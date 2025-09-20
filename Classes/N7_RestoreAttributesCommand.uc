class N7_RestoreAttributesCommand extends N7_BinaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
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
    return ExecState.GetArgC() > 0 || ExecState.GetArgC() == 0 && !KFGT.IsInState('PendingMatch') && (KFGT.WaveCountDown > 0 || HasAdminAccess(ExecState.GetSender()));
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
protected function bool CheckIfNonAdminExecutionAllowed(N7_CommandExecutionState ExecState)
{
    return ExecState.GetArgC() <= 1 || ExecState.GetArg(ECmdArgs.ARG_TARGETNAME) == ExecState.GetSender().PlayerReplicationInfo.PlayerName;
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string AttrState, TargetName;

    AttrState = ColorizeValue(ExecState.LoadEnabled());
    TargetName = LoadTarget(ExecState);

    switch (ExecState.GetArgC())
    {
        case 0:
            return "Your attributes have been restored";

        case 1:
        case 2:
            if (TargetName ~= "all")
            {
                return "Attribute restoration is "$AttrState$" for all players";
            }

            return "Attribute restoration is "$AttrState;
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
    ArgTypes(0)="switch"
    Aliases(0)="AR"
    Description="Restore HP/Armor/Ammo. Admin access allows for restoring other players attributes"
    Signature="<? (0 | 1 | ON | OFF), adminonly ? (string TargetName | 'all')>"
}
