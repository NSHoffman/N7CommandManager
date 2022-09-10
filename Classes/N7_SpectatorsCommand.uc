class N7_SpectatorsCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWSPECS,
};

var protected const int MinSpectators;
var protected const int MaxSpectators;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewSpectators;

    if (ExecState.GetArgC() > 0)
    {
        NewSpectators = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWSPECS));
        KFGT.MaxSpectators = NewSpectators;
    }
    else
    {
        KFGT.MaxSpectators = KFGT.default.MaxSpectators;
    }
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int NewSpectators, MinSpectatorsActual;

    if (ExecState.GetArgC() > 0)
    {
        NewSpectators = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWSPECS));
        MinSpectatorsActual = Max(KFGT.NumSpectators, MinSpectators);

        if (!IsInRange(NewSpectators, MinSpectatorsActual, MaxSpectators))
        {
            return false;
        }
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Max Spectators set to "$KFGT.MaxSpectators$" by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "New Spectators number must be in range from "$Max(KFGT.NumSpectators, MinSpectators)$" to "$MaxSpectators;
}

defaultproperties
{
    MinSpectators=0
    MaxSpectators=10
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="SPEC"
    Aliases(1)="SPECS"
    ArgTypes(0)="number"
    Signature="<? int NewSpectators>"
    Description="Set maximum number of spectators"
}
