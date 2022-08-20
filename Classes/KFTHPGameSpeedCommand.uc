class KFTHPGameSpeedCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWSPEED,
};

var protected const float MinGameSpeed;
var protected const float MaxGameSpeed;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local float NewGameSpeed;

    NewGameSpeed = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWSPEED));
    KFGT.SetGameSpeed(NewGameSpeed);
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local float NewGameSpeed;

    NewGameSpeed = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWSPEED));

    if (!IsInRangeF(NewGameSpeed, MinGameSpeed, MaxGameSpeed))
    {
        return false;
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "Game Speed set to "$KFGT.GameSpeed$" by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "New Game Speed must be in range from "$MinGameSpeed$" to "$MaxGameSpeed;
}

defaultproperties
{
    bAdminOnly=true
    MinGameSpeed=0.25
    MaxGameSpeed=10.0
    MinArgsNum=1
    MaxArgsNum=1
    Aliases(0)="GS"
    Aliases(1)="GAMESPEED"
    Aliases(2)="SLOMO"
    ArgTypes(0)="number"
    Signature="<int | float NewGameSpeed>"
    Description="Set Game Speed"
}
