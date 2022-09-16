class N7_SpawnRateCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_SPAWNRATE,
};

var protected const float MinRate;
var protected globalconfig const float MaxRate;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local float NewSpawnRate;

    if (ExecState.GetArgC() > 0)
    {
        NewSpawnRate = ToFloat(ExecState.GetArg(ECmdArgs.ARG_SPAWNRATE));
        KFGT.KFLRules.WaveSpawnPeriod = NewSpawnRate;
    }
    else
    {
        KFGT.KFLRules.WaveSpawnPeriod = KFGT.KFLRules.default.WaveSpawnPeriod;
    }
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local float NewSpawnRate;

    if (ExecState.GetArgC() > 0)
    {
        NewSpawnRate = ToFloat(ExecState.GetArg(ECmdArgs.ARG_SPAWNRATE));

        if (!IsInRangeF(NewSpawnRate, MinRate, MaxRate))
        {
            return false;
        }
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Spawn Rate set to "$ColorizeValue(KFGT.KFLRules.WaveSpawnPeriod)$" by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Spawn Rate number must be in range from "$MinRate$" to "$MaxRate;
}

defaultproperties
{
    MinRate=0.0
    MaxRate=10.0
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="SR"
    Aliases(1)="SETSR"
    ArgTypes(0)="number"
    Signature="<? int | float SpawnRate>"
    Description="Set interval between ZED squads spawn"
}
