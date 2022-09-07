class KFTHPKillZedsCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_TARGET,
};

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
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
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    return ExecState.GetArgC() == 0 
        || ExecState.GetArgC() == 1 && Locs(ExecState.GetArg(ECmdArgs.ARG_TARGET)) == "all";
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    if (ExecState.GetArgC() == 1)
    {
        return "All ZEDs killed by "$GetInstigatorName(ExecState);
    }

    return "ZED Squads killed by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "Command only accepts 'all' as an argument";
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="KZ"
    Aliases(1)="KILLZEDS"
    ArgTypes(0)="word"
    Signature="<? string 'all'>"
    Description="Kill ZEDs"
}
