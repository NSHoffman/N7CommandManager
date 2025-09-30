class N7_WaveIntervalCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWTIME,
};

var protected const int MinLimit;
var protected config const int MaxLimit;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewWaveInterval;

    if (ExecState.GetArgC() > 0)
    {
        NewWaveInterval = int(ExecState.GetArg(ECmdArgs.ARG_NEWTIME));
        KFGT.TimeBetweenWaves = Clamp(NewWaveInterval, MinLimit, MaxLimit);
    }
    else
    {
        KFGT.TimeBetweenWaves = KFGT.default.TimeBetweenWaves;
    }
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Wave Interval set to "$ColorizeValue(KFGT.TimeBetweenWaves)$"s by "$ColorizeSender(ExecState);
}

defaultproperties
{
    MaxArgsNum=1
    ArgTypes(0)="number"

    MinLimit=6
    MaxLimit=600

    Aliases(0)="WI"
    Aliases(1)="WT"
    Aliases(2)="INTERVAL"
    Description="Set interval between waves"
    Signature="<? int WaveInterval>"
}
