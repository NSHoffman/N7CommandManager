class N7_KillZedsCommand extends N7_Command;

enum ECmdArgs
{
    ARG_TARGET,
};

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    switch (ExecState.GetArgC())
    {
        case 0:
            GSU.KillLivingZeds();
            break;

        case 1:
            GSU.KillAllZeds();
            break;
    }

    GSU.StopZedTime();
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    return ExecState.GetArgC() == 0 
        || ExecState.GetArgC() == 1 && ExecState.GetArg(ECmdArgs.ARG_TARGET) ~= "all";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    if (ExecState.GetArgC() == 1)
    {
        return "All ZEDs killed by "$ColorizeSender(ExecState);
    }

    return "ZED Squads killed by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Command only accepts 'all' as an argument";
}

defaultproperties
{
    Aliases(0)="KZ"
    Aliases(1)="KILLZEDS"
    MinArgsNum=0
    MaxArgsNum=1
    ArgTypes(0)="word"
    Signature="<? 'all'>"
    Description="Kill ZEDs"
    bNotifySenderOnSuccess=False
    bNotifyGlobalOnSuccess=True
}
