class N7_SetWaveCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_WAVE,
};

var protected const int MinLimit;
var protected int MaxLimit;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewWaveNum;

    NewWaveNum = int(ExecState.GetArg(ECmdArgs.ARG_WAVE));

    GSU.SetWave(NewWaveNum);
    ExecState.SaveNumber(NewWaveNum);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress') || KFGT.bGameEnded && KFGameReplicationInfo(Level.Game.GameReplicationInfo).EndGameType == 1;
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int WaveNum;
    MaxLimit = KFGT.FinalWave + 2;
    WaveNum = int(ExecState.GetArg(ECmdArgs.ARG_WAVE));

    return IsInRange(WaveNum, MinLimit, MaxLimit);
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string StyledWaveNum;
    StyledWaveNum = ColorizeValue(ExecState.LoadNumber());

    return "Wave set to "$StyledWaveNum$" by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Wave can be changed only during the game";
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Wave number must be in range from "$MinLimit$" to "$MaxLimit;
}

defaultproperties
{
    MinArgsNum=1
    MaxArgsNum=1
    ArgTypes(0)="number"

    MinLimit=1
    MaxLimit=11

    Aliases(0)="WN"
    Aliases(1)="FW"
    Aliases(2)="WAVE"
    Aliases(3)="WAVENUM"
    Aliases(4)="SETWAVE"
    Aliases(5)="WAVENUM"
    Description="Set wave number"
    Signature="<int WaveNum>"
}
