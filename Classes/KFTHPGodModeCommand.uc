class KFTHPGodModeCommand extends KFTHPBinaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    switch (ExecState.GetArgC())
    {
        case 0:
            PC.bGodMode = !PC.bGodMode;
            break;

        case 1:
        case 2:
            if (IsSwitchOnValue(ExecState.GetArg(ECmdArgs.ARG_VALUE)))
            {
                PC.bGodMode = true;
            }
            else
            {
                PC.bGodMode = false;
            }
            break;
    }

    KFTHPCommandPreservingState(ExecState).SaveFlag(PC.bGodMode);
}

/** @Override */
protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return "Cannot find player with name "$KFTHPCommandPreservingState(ExecState).LoadString();
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = KFTHPCommandPreservingState(ExecState).LoadString();

    if (TargetName ~= "all")
    {
        return "All players' God Mode is "$KFTHPCommandPreservingState(ExecState).LoadEnabled();
    }

    return "God Mode is "$KFTHPCommandPreservingState(ExecState).LoadEnabled();
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = KFTHPCommandPreservingState(ExecState).LoadString();

    if (TargetName ~= "all")
    {
        return "All players' God Mode is "$KFTHPCommandPreservingState(ExecState).LoadEnabled();
    }

    return TargetName$"'s God Mode is "$KFTHPCommandPreservingState(ExecState).LoadEnabled();
}

defaultproperties
{
    Aliases(0)="GM"
    Aliases(1)="GOD"
    ArgTypes(0)="switch"
    Signature="<optional (0 | 1 | ON | OFF) Flag, optional (string TargetName | 'all')>"
    Description="Toggle God Mode"
    bAdminOnly=true
    bNotifyGlobalOnSuccess=true
}
