class N7_SpawnRateCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_SPAWNRATE,
};

var protected const float MinLimit;
var protected config const float MaxLimit;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local float NewSpawnRate;

    if (ExecState.GetArgC() > 0)
    {
        NewSpawnRate = float(ExecState.GetArg(ECmdArgs.ARG_SPAWNRATE));
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
        NewSpawnRate = float(ExecState.GetArg(ECmdArgs.ARG_SPAWNRATE));

        if (!IsInRangeF(NewSpawnRate, MinLimit, MaxLimit))
        {
            return False;
        }
    }

    return True;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Spawn Rate set to "$ColorizeValue(KFGT.KFLRules.WaveSpawnPeriod)$" by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Spawn Rate number must be in range from "$MinLimit$" to "$MaxLimit;
}

defaultproperties
{
    MaxArgsNum=1
    ArgTypes(0)="number"

    MaxLimit=10.0

    Aliases(0)="SR"
    Aliases(1)="SETSR"
    Description="Set interval between ZED squads spawn"
    Signature="<? float SpawnRate>"
}
