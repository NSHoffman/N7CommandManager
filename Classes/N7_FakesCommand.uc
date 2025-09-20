class N7_FakesCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWFAKES,
};

var protected const int MinLimit;
var protected config const int MaxLimit;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewFakes;

    if (ExecState.GetArgC() > 0)
    {
        NewFakes = int(ExecState.GetArg(ECmdArgs.ARG_NEWFAKES));
    }
    else
    {
        NewFakes = 0;
    }

    SetFakedPlayersNum(NewFakes);
    KFGT.NumPlayers = GetRealPlayersNum() + GetFakedPlayersNum();
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int NewFakes;

    if (ExecState.GetArgC() > 0)
    {
        NewFakes = int(ExecState.GetArg(ECmdArgs.ARG_NEWFAKES));

        if (!IsInRange(NewFakes, MinLimit, MaxLimit))
        {
            return False;
        }
    }

    return True;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string StyledFakedNum;
    StyledFakedNum = ColorizeValue(KFGT.NumPlayers - GSU.GetRealPlayersNum());

    return "Faked Players set to "$StyledFakedNum$" by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Faked players number must be in range from "$MinLimit$" to "$MaxLimit;
}

defaultproperties
{
    MaxArgsNum=1
    ArgTypes(0)="number"

    MaxLimit=10

    Aliases(0)="FAKE"
    Aliases(1)="FAKES"
    Aliases(2)="FAKED"
    Aliases(3)="SETFAKED"
    Aliases(4)="SETFAKES"
    Description="Set number of faked players"
    Signature="<? int Fakes>"
}
