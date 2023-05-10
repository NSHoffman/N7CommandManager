class N7_SlotsCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWSLOTS,
};

var protected const int MinLimit;
var protected config const int MaxLimit;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewSlots;

    if (ExecState.GetArgC() > 0)
    {
        NewSlots = int(ExecState.GetArg(ECmdArgs.ARG_NEWSLOTS));
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
    local int NewSlots;

    if (ExecState.GetArgC() > 0)
    {
        NewSlots = int(ExecState.GetArg(ECmdArgs.ARG_NEWSLOTS));

        if (!IsInRange(NewSlots, MinLimit, MaxLimit))
        {
            return False;
        }
    }

    return True;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Max Players set to "$ColorizeValue(KFGT.MaxPlayers)$" by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "New slots number must be in range from "$MinLimit$" to "$MaxLimit;
}

defaultproperties
{
    Aliases(0)="SLOT"
    Aliases(1)="SLOTS"
    MinLimit=1
    MaxLimit=10
    MinArgsNum=0
    MaxArgsNum=1
    ArgTypes(0)="number"
    Signature="<? int NewSlots>"
    Description="Set maximum number of players"
}
