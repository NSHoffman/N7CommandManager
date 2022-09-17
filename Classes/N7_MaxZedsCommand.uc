class N7_MaxZedsCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_MAXZEDS,
};

var protected config const int MinLimit;
var protected config const int MaxLimit;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewMaxZeds;

    if (ExecState.GetArgC() > 0)
    {
        NewMaxZeds = ToInt(ExecState.GetArg(ECmdArgs.ARG_MAXZEDS));

        KFGT.MaxZombiesOnce = NewMaxZeds;
        KFGT.StandardMaxZombiesOnce = NewMaxZeds;
        KFGT.MaxMonsters = NewMaxZeds;
    }
    else
    {
        KFGT.MaxZombiesOnce = KFGT.default.MaxZombiesOnce;
        KFGT.StandardMaxZombiesOnce = KFGT.default.StandardMaxZombiesOnce;
        KFGT.MaxMonsters = KFGT.default.MaxMonsters;
    }
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int NewMaxZeds;

    if (ExecState.GetArgC() > 0)
    {
        NewMaxZeds = ToInt(ExecState.GetArg(ECmdArgs.ARG_MAXZEDS));

        if (!IsInRange(NewMaxZeds, MinLimit, MaxLimit))
        {
            return false;
        }
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Max Zeds set to "$ColorizeValue(KFGT.MaxZombiesOnce)$" by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Max Zeds number must be in range from "$MinLimit$" to "$MaxLimit;
}

defaultproperties
{
    MinLimit=0
    MaxLimit=100
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="MZ"
    Aliases(1)="SETMZ"
    Aliases(2)="MAXZEDS"
    ArgTypes(0)="number"
    Signature="<? int MaxZeds>"
    Description="Set max number of ZEDs present at a time"
}
