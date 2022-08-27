class KFTHPRestoreAttrsCommand extends KFTHPTargetCommand;

enum ECmdArgs
{
    ARG_FLAG,
};

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
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
                KFTHPCommandPreservingState(ExecState).SaveFlag(true);
            }
            else
            {
                RemoveRestoredPlayer(PC);
                KFTHPCommandPreservingState(ExecState).SaveFlag(false);
            }
            break;
    }
}

/** @Override */
protected function bool ShouldBeTarget(
    KFTHPCommandExecutionState ExecState, 
    PlayerController PC)
{
    return PC == ExecState.GetSender();
}

/** @Override */
protected function bool CheckGameState(KFTHPCommandExecutionState ExecState)
{
    if (ExecState.GetArgC() == 1 || ExecState.GetArgC() == 0 && KFGT.IsInState('MatchInProgress'))
    {
        return true;
    }

    return false;
}

/** @Override */
protected function bool CheckTargets(KFTHPCommandExecutionState ExecState)
{
    switch (ExecState.GetArgC())
    {
        case 0:
            return IsAlive(ExecState.GetSender());

        case 1:
            return true;
    }

    return false;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Attributes can be restored only during the game";
}

/** @Override */
protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return "Cannot restore attributes of dead players";
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    if (ExecState.GetArgC() == 0)
    {
        return "Your attributes have been restored";
    }

    return "Attribute restoration is "$KFTHPCommandPreservingState(ExecState).LoadEnabled();
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="AR"
    ArgTypes(0)="switch"
    Signature="<optional (0 | 1 | ON | OFF)>"
    Description="Restore HP/Armor/Ammo. If argument is passed - toggle restore before and after each wave"
    CommandStateClass=Class'KFTHPCommandPreservingState'
}
