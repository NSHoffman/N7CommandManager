class KFTHPZedTimeCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_FLAG,
};

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
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

    KFTHPCommandPreservedState(ExecState).SaveFlag(!IsZedTimeDisabled());
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "ZED-Time is "$KFTHPCommandPreservedState(ExecState).LoadEnabled()$" by "$GetInstigatorName(ExecState);
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
