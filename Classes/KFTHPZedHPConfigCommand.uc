class KFTHPZedHPConfigCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_HPCONFIG,
};

var protected const int MinLimit;
var protected const int MaxLimit;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local int NewHPConfig;

    NewHPConfig = ToInt(ExecState.GetArg(ECmdArgs.ARG_HPCONFIG));
    SetZedHPConfig(NewHPConfig);
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local int NewHPConfig, MinLimitActual;

    NewHPConfig = ToInt(ExecState.GetArg(ECmdArgs.ARG_HPCONFIG));

    MinLimitActual = Min(
        ZedHPConfigThreshold, 
        Max(MinLimit, GSU.GetAlivePlayersNum())
    );

    if (!IsInRange(NewHPConfig, MinLimitActual, MaxLimit))
    {
        KFTHPCommandPreservingState(ExecState).SaveMinLimit(MinLimitActual);

        return false;
    }


    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "HP Config set to "$GSU.GetFinalZedHPConfig()$" by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "HP config must be in range from "$KFTHPCommandPreservingState(ExecState).LoadMinLimit()$" to "$MaxLimit;
}

defaultproperties
{
    MinLimit=1
    MaxLimit=10
    MinArgsNum=1
    MaxArgsNum=1
    Aliases(0)="HP"
    Aliases(1)="SETHP"
    ArgTypes(0)="number"
    Signature="<int HPConfig>"
    Description="Set HP multiplier for ZEDs"
    CommandStateClass=Class'KFTHPCommandPreservingState'
}
