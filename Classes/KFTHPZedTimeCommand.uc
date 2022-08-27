class KFTHPZedTimeCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_FLAG,
};

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local string Flag;

    if (ExecState.GetArgC() == 1)
    {
        Flag = ExecState.GetArg(ECmdArgs.ARG_FLAG);

        if (IsSwitchOnValue(Flag))
        {
            SetZedTime(false);
        }
        else if (IsSwitchOffValue(Flag))
        {
            SetZedTime(true);
        }
    }
    else
    {
        SetZedTime(!IsZedTimeDisabled());
    }

    KFTHPCommandPreservingState(ExecState).SaveFlag(!IsZedTimeDisabled());
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "ZED-Time is "$KFTHPCommandPreservingState(ExecState).LoadEnabled()$" by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="ZT"
    ArgTypes(0)="switch"
    Signature="<optional (0 | 1 | ON | OFF)>"
    Description="Toggle ZED-Time"
}
