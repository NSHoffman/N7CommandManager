class N7_ZedHPConfigCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_HPCONFIG,
};

var protected const int MinLimit;
var protected config const int MaxLimit;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewHPConfig;

    if (ExecState.GetArgC() > 0)
    {
        NewHPConfig = int(ExecState.GetArg(ECmdArgs.ARG_HPCONFIG));
    }
    else
    {
        NewHPConfig = 1;
    }

    HPConfigModel.SetZedHPConfig(NewHPConfig);
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int NewHPConfig, MinLimitActual;

    if (ExecState.GetArgC() > 0)
    {
        NewHPConfig = int(ExecState.GetArg(ECmdArgs.ARG_HPCONFIG));

        MinLimitActual = Min(
            GetZedHPConfigThreshold(),
            Max(MinLimit, GetAlivePlayersNum())
        );

        if (!IsInRange(NewHPConfig, MinLimitActual, MaxLimit))
        {
            ExecState.SaveMinLimit(MinLimitActual);
            return False;
        }
    }

    return True;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "HP Config set to "$ColorizeValue(GetZedHPConfig())$" by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "HP config must be in range from "$ExecState.LoadMinLimit()$" to "$MaxLimit;
}

defaultproperties
{
    Aliases(0)="HP"
    Aliases(1)="SETHP"
    MinLimit=1
    MaxLimit=10
    MinArgsNum=0
    MaxArgsNum=1
    ArgTypes(0)="number"
    Signature="<? int HPConfig>"
    Description="Set HP multiplier for ZEDs"
}
