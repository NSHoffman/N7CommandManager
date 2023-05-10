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

        if (IsInRange(NewWaveInterval, MinLimit, MaxLimit))
        {
            KFGT.TimeBetweenWaves = NewWaveInterval; 
        }
        else if (IsInRange(NewWaveInterval, MinLimit))
        {
            KFGT.TimeBetweenWaves = MaxLimit;
        }
        else
        {
            KFGT.TimeBetweenWaves = MinLimit;
        }
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
    Aliases(0)="WI"
    Aliases(1)="WT"
    Aliases(2)="INTERVAL"
    MinLimit=6
    MaxLimit=600
    MinArgsNum=0
    MaxArgsNum=1
    ArgTypes(0)="number"
    Signature="<? int WaveInterval>"
    Description="Set interval between waves"
}
