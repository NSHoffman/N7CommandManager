class N7_ZedHPConfigCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_HPCONFIG,
};

var protected const int MinLimit;
var protected const int MaxLimit;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewHPConfig;

    if (ExecState.GetArgC() > 0)
    {
        NewHPConfig = ToInt(ExecState.GetArg(ECmdArgs.ARG_HPCONFIG));
    }
    else
    {
        NewHPConfig = 1;
    }

    SetZedHPConfig(NewHPConfig);
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int NewHPConfig, MinLimitActual;

    if (ExecState.GetArgC() > 0)
    {
        NewHPConfig = ToInt(ExecState.GetArg(ECmdArgs.ARG_HPCONFIG));

        MinLimitActual = Min(
            ZedHPConfigThreshold, 
            Max(MinLimit, GSU.GetAlivePlayersNum())
        );

        if (!IsInRange(NewHPConfig, MinLimitActual, MaxLimit))
        {
            N7_CommandPreservedState(ExecState).SaveMinLimit(MinLimitActual);
            return false;
        }
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "HP Config set to "$GSU.GetFinalZedHPConfig()$" by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "HP config must be in range from "$N7_CommandPreservedState(ExecState).LoadMinLimit()$" to "$MaxLimit;
}

defaultproperties
{
    MinLimit=1
    MaxLimit=10
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="HP"
    Aliases(1)="SETHP"
    ArgTypes(0)="number"
    Signature="<? int HPConfig>"
    Description="Set HP multiplier for ZEDs"
}
