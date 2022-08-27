class KFTHPWaveIntervalCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWTIME,
};

var protected const int MinWaveInterval;
var protected const int MaxWaveInterval;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local int NewWaveInterval;

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

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "Wave Interval set to "$KFGT.TimeBetweenWaves$"s by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    MinArgsNum=1
    MaxArgsNum=1
    MinWaveInterval=6
    MaxWaveInterval=600
    Aliases(0)="WI"
    Aliases(1)="WT"
    Aliases(2)="INTERVAL"
    ArgTypes(0)="number"
    Signature="<int WaveInterval>"
    Description="Set interval between waves"
}
