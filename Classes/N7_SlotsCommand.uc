class N7_SlotsCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWSLOTS,
};

var protected const int MinSlots;
var protected const int MaxSlots;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewSlots;

    if (ExecState.GetArgC() > 0)
    {
        NewSlots = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWSLOTS));
        KFGT.MaxPlayers = NewSlots;
    }
    else
    {
        KFGT.MaxPlayers = KFGT.default.MaxPlayers;
    }
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int NewSlots, MinSlotsActual;

    if (ExecState.GetArgC() > 0)
    {
        NewSlots = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWSLOTS));
        MinSlotsActual = Max(KFGT.NumPlayers, MinSlots);

        if (!IsInRange(NewSlots, MinSlotsActual, MaxSlots))
        {
            return false;
        }
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Max Players set to "$KFGT.MaxPlayers$" by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "New slots number must be in range from "$Max(KFGT.NumPlayers, MinSlots)$" to "$MaxSlots;
}

defaultproperties
{
    MinSlots=1
    MaxSlots=10
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="SLOT"
    Aliases(1)="SLOTS"
    ArgTypes(0)="number"
    Signature="<? int NewSlots>"
    Description="Set maximum number of players"
}
