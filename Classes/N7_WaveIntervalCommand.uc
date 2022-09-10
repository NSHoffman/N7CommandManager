class N7_WaveIntervalCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWTIME,
};

var protected const int MinWaveInterval;
var protected const int MaxWaveInterval;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewWaveInterval;

    if (ExecState.GetArgC() > 0)
    {
        NewWaveInterval = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWTIME));

        if (IsInRange(NewWaveInterval, MinWaveInterval, MaxWaveInterval))
        {
            KFGT.TimeBetweenWaves = NewWaveInterval; 
        }
        else if (IsInRange(NewWaveInterval, MinWaveInterval))
        {
            KFGT.TimeBetweenWaves = MaxWaveInterval;
        }
        else
        {
            KFGT.TimeBetweenWaves = MinWaveInterval;
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
    return "Wave Interval set to "$KFGT.TimeBetweenWaves$"s by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=1
    MinWaveInterval=6
    MaxWaveInterval=600
    Aliases(0)="WI"
    Aliases(1)="WT"
    Aliases(2)="INTERVAL"
    ArgTypes(0)="number"
    Signature="<? int WaveInterval>"
    Description="Set interval between waves"
}
