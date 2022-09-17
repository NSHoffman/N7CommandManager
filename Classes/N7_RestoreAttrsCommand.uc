class N7_RestoreAttrsCommand extends N7_TargetCommand;

enum ECmdArgs
{
    ARG_FLAG,
};

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
            if (IsSwitchOnValue(ExecState.GetArg(ECmdArgs.ARG_FLAG)))
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
protected function bool ShouldBeTarget(
    N7_CommandExecutionState ExecState, 
    PlayerController PC)
{
    return AcceptTargetBySender(ExecState, PC);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return ExecState.GetArgC() == 1 
        || ExecState.GetArgC() == 0 && KFGT.IsInState('MatchInProgress') && KFGT.WaveCountDown > 0;
}

/** @Override */
protected function bool CheckTargets(N7_CommandExecutionState ExecState)
{
    local string TargetName;

    switch (ExecState.GetArgC())
    {
        case 0:
            return VerifyTargetBySender(ExecState, TargetName);

        case 1:
            return True;
    }

    return False;
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
    if (ExecState.GetArgC() == 0)
    {
        return "Your attributes have been restored";
    }

    return "Attribute restoration is "$ColorizeValue(ExecState.LoadEnabled());
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="AR"
    ArgTypes(0)="switch"
    Signature="<? (0 | 1 | ON | OFF)>"
    Description="Restore HP/Armor/Ammo. If argument is passed - toggle restore before and after each wave"
}
