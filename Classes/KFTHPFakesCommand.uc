class KFTHPFakesCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWFAKES,
};

var protected const int MinFakes;
var protected const int MaxFakes;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local int NewFakes;

    NewFakes = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWFAKES));
    SetFakedPlayersNum(NewFakes);

    KFGT.NumPlayers = GSU.GetRealPlayersNum() + GetFakedPlayersNum();
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local int NewFakes, MaxFakesActual;

    NewFakes = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWFAKES));
    MaxFakesActual = Min(KFGT.MaxPlayers - (KFGT.NumPlayers - FakedPlayersNum), MaxFakes);

    if (!IsInRange(NewFakes, MinFakes, MaxFakesActual))
    {
        KFTHPCommandPreservingState(ExecState).SaveMaxLimit(MaxFakesActual);

        return false;
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "Faked Players set to "$(KFGT.NumPlayers - GSU.GetRealPlayersNum())$" by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "Faked players number must be in range from "$MinFakes$" to "$KFTHPCommandPreservingState(ExecState).LoadMaxLimit();
}

defaultproperties
{
    MinFakes=0
    MaxFakes=10
    MinArgsNum=1
    MaxArgsNum=1
    Aliases(0)="FAKE"
    Aliases(1)="FAKES"
    Aliases(2)="FAKED"
    Aliases(3)="SETFAKED"
    Aliases(4)="SETFAKES"
    ArgTypes(0)="number"
    Signature="<int NewFakes>"
    Description="Set number of faked players"
}
