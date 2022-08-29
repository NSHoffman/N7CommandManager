class KFTHPMaxZedsCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_MAXZEDS,
};

var protected const int MinLimit;
var protected const int MaxLimit;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
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
        KFGT.MaxZombiesOnce = KFGT.Default.MaxZombiesOnce;
        KFGT.StandardMaxZombiesOnce = KFGT.Default.StandardMaxZombiesOnce;
        KFGT.MaxMonsters = KFGT.Default.MaxMonsters;
    }
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
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
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "Max Zeds set to "$KFGT.MaxZombiesOnce$" by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "Max Zeds number must be in range from "$MinLimit$" to "$MaxLimit;
}

defaultproperties
{
    MinLimit=4
    MaxLimit=96
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="MZ"
    Aliases(1)="SETMZ"
    Aliases(2)="MAXZEDS"
    ArgTypes(0)="number"
    Signature="<? int MaxZeds>"
    Description="Set max number of ZEDs present at a time"
}
