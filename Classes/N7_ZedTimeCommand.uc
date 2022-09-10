class N7_ZedTimeCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_FLAG,
};

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local bool bShouldEnableZedTime;

    if (ExecState.GetArgC() == 1)
    {
        bShouldEnableZedTime = ToBool(ExecState.GetArg(ECmdArgs.ARG_FLAG));
        SetZedTime(bShouldEnableZedTime);
    }
    else
    {
        SetZedTime(!IsZedTimeDisabled());
    }

    N7_CommandPreservedState(ExecState).SaveFlag(!IsZedTimeDisabled());
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "ZED-Time is "$N7_CommandPreservedState(ExecState).LoadEnabled()$" by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="ZT"
    ArgTypes(0)="switch"
    Signature="<? (0 | 1 | ON | OFF)>"
    Description="Toggle ZED-Time"
}
