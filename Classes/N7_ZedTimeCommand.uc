class N7_ZedTimeCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_FLAG,
};

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local bool bEnableZedTime;

    if (ExecState.GetArgC() == 1)
    {
        bEnableZedTime = ToBool(ExecState.GetArg(ECmdArgs.ARG_FLAG));
        SetZedTime(bEnableZedTime);
    }
    else
    {
        SetZedTime(!IsZedTimeEnabled());
    }

    ExecState.SaveFlag(IsZedTimeEnabled());
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string ZedTimeState;
    ZedTimeState = ColorizeValue(ExecState.LoadEnabled());

    return "ZED-Time is "$ZedTimeState$" by "$ColorizeSender(ExecState);
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
