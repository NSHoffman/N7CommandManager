class N7_GameSpeedCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWSPEED,
};

var protected const float MinGameSpeed;
var protected const float MaxGameSpeed;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local float NewGameSpeed;

    if (ExecState.GetArgC() > 0)
    {
        NewGameSpeed = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWSPEED));
        KFGT.SetGameSpeed(NewGameSpeed);
    }
    else
    {
        KFGT.SetGameSpeed(1.0);
    }
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local float NewGameSpeed;

    if (ExecState.GetArgC() > 0)
    {
        NewGameSpeed = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWSPEED));

        if (!IsInRangeF(NewGameSpeed, MinGameSpeed, MaxGameSpeed))
        {
            return false;
        }
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Game Speed set to "$KFGT.GameSpeed$" by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "New Game Speed must be in range from "$MinGameSpeed$" to "$MaxGameSpeed;
}

defaultproperties
{
    bAdminOnly=true
    MinGameSpeed=0.25
    MaxGameSpeed=10.0
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="GS"
    Aliases(1)="GAMESPEED"
    Aliases(2)="SLOMO"
    ArgTypes(0)="number"
    Signature="<? int | float NewGameSpeed>"
    Description="Set Game Speed"
}
