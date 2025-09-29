class N7_GodModeCommand extends N7_BinaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    switch (ExecState.GetArgC())
    {
        case 0:
            PC.bGodMode = !PC.bGodMode;
            break;

        case 1:
        case 2:
            PC.bGodMode = ToBool(ExecState.GetArg(ECmdArgs.ARG_VALUE));
            break;
    }

    ExecState.SaveFlag(PC.bGodMode);
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, GodModeState;

    TargetName = LoadTarget(ExecState);
    GodModeState = ColorizeValue(ExecState.LoadEnabled());

    if (TargetName ~= "all")
    {
        return "All players' God Mode is "$GodModeState;
    }

    return "God Mode is "$GodModeState;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, GodModeState;

    TargetName = LoadTarget(ExecState);
    GodModeState = ColorizeValue(ExecState.LoadEnabled());

    if (TargetName ~= "all")
    {
        return "All players' God Mode is "$GodModeState;
    }

    return ColorizeTarget(TargetName)$"'s God Mode is "$GodModeState;
}

defaultproperties
{
    ArgTypes(0)="switch"

    Aliases(0)="GM"
    Aliases(1)="GOD"
    Description="Toggle god mode"
    Signature="<? (0 | 1 | ON | OFF), ? (string TargetName | 'all')>"

    bNotifyGlobalOnSuccess=True

    bAdminOnly=True
}
