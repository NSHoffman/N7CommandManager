class N7_FakesCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWFAKES,
};

var protected const int MinFakes;
var protected globalconfig const int MaxFakes;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewFakes;

    if (ExecState.GetArgC() > 0)
    {
        NewFakes = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWFAKES));
    }
    else
    {
        NewFakes = 0;
    }

    SetFakedPlayersNum(NewFakes);
    KFGT.NumPlayers = GSU.GetRealPlayersNum() + GetFakedPlayersNum();
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int NewFakes, MaxFakesActual;

    if (ExecState.GetArgC() > 0)
    {
        NewFakes = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWFAKES));
        MaxFakesActual = Max(0, Min(KFGT.MaxPlayers - (KFGT.NumPlayers - FakedPlayersNum), MaxFakes));

        if (!IsInRange(NewFakes, MinFakes, MaxFakesActual))
        {
            ExecState.SaveMaxLimit(MaxFakesActual);

            return false;
        }
    }

    return true;
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
    return "Faked players number must be in range from "$MinFakes$" to "$ExecState.LoadMaxLimit();
}

defaultproperties
{
    MinFakes=0
    MaxFakes=10
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="FAKE"
    Aliases(1)="FAKES"
    Aliases(2)="FAKED"
    Aliases(3)="SETFAKED"
    Aliases(4)="SETFAKES"
    ArgTypes(0)="number"
    Signature="<? int NewFakes>"
    Description="Set number of faked players"
}