class KFTHPGodModeCommand extends KFTHPTargetCommand;

enum ECmdArgs
{
    ARG_FLAG,
    ARG_TARGETNAME,
};

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
            if (IsSwitchOnValue(ExecState.GetArg(ECmdArgs.ARG_FLAG)))
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
protected function bool CheckTargets(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;

    switch (ExecState.GetArgC())
    {
        case 0:
        case 1:
            return true;

        case 2:
            TargetName = ExecState.GetArg(ECmdArgs.ARG_TARGETNAME);
            KFTHPCommandPreservingState(ExecState).SaveString(TargetName);

            return TargetName ~= "all" || DoesTargetExist(TargetName);
    }

    return false;
}

/** @Override */
protected function bool ShouldBeTarget(
    KFTHPCommandExecutionState ExecState, 
    PlayerController PC)
{
    local string TargetName;
    
    switch (ExecState.GetArgC())
    {
        case 0:
        case 1:
            return PC == ExecState.GetSender();

        case 2:
            TargetName = ExecState.GetArg(ECmdArgs.ARG_TARGETNAME);

            if (TargetName ~= "all")
            {
                return true;
            }
            return IsStringPartOf(TargetName, PC.PlayerReplicationInfo.PlayerName);
    }

    return false;
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
    MinArgsNum=0
    MaxArgsNum=2
    Aliases(0)="GM"
    Aliases(1)="GOD"
    ArgTypes(0)="switch"
    ArgTypes(1)="any"
    Signature="<optional (0 | 1 | ON | OFF) Flag, optional (string TargetName | 'all')>"
    Description="Toggle God Mode"
    bAdminOnly=true
    bNotifyGlobalOnSuccess=true
    CommandStateClass=Class'KFTHPCommandPreservingState'
}
