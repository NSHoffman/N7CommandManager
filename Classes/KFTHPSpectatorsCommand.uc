class KFTHPSpectatorsCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWSPECS,
};

var protected const int MinSpectators;
var protected const int MaxSpectators;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local int NewSpectators;

    NewSpectators = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWSPECS));
    KFGT.MaxSpectators = NewSpectators;
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local int NewSpectators, MinSpectatorsActual;

    NewSpectators = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWSPECS));
    MinSpectatorsActual = Max(KFGT.NumSpectators, MinSpectators);

    if (!IsInRange(NewSpectators, MinSpectatorsActual, MaxSpectators))
    {
        return false;
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "Max Spectators set to "$KFGT.MaxSpectators$" by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "New Spectators number must be in range from "$Max(KFGT.NumSpectators, MinSpectators)$" to "$MaxSpectators;
}

defaultproperties
{
    MinSpectators=0
    MaxSpectators=10
    MinArgsNum=1
    MaxArgsNum=1
    Aliases(0)="SPEC"
    Aliases(1)="SPECS"
    ArgTypes(0)="number"
    Signature="<int NewSpectators>"
    Description="Set maximum of spectators allowed"
}
