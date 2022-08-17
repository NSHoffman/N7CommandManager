class KFTHPSpawnRateCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_SPAWNRATE,
};

var protected const float MinRate;
var protected const float MaxRate;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local float NewSpawnRate;

    NewSpawnRate = ToFloat(ExecState.GetArg(ECmdArgs.ARG_SPAWNRATE));
    KFGT.KFLRules.WaveSpawnPeriod = NewSpawnRate;
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local float NewSpawnRate;

    NewSpawnRate = ToFloat(ExecState.GetArg(ECmdArgs.ARG_SPAWNRATE));

    if (!IsInRangeF(NewSpawnRate, MinRate, MaxRate))
    {
        return false;
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "Spawn Rate set to "$KFGT.KFLRules.WaveSpawnPeriod$" by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "Spawn Rate number must be in range from "$MinRate$" to "$MaxRate;
}

defaultproperties
{
    MinRate=0.0
    MaxRate=10.0
    MinArgsNum=1
    MaxArgsNum=1
    Aliases(0)="SR"
    Aliases(1)="SETSR"
    ArgTypes(0)="number"
    Signature="<int | float SpawnRate>"
    Description="Set interval between ZED squads spawn"
}
