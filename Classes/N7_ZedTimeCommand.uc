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
    return "ZED-Time is "$ColorizeValue(ExecState.LoadEnabled())$" by "$ColorizeSender(ExecState);
}

defaultproperties
{
    MaxArgsNum=1
    ArgTypes(0)="switch"

    Aliases(0)="ZT"
    Description="Toggle ZED-Time"
    Signature="<? (0 | 1 | ON | OFF)>"
}
