class N7_GameSpeedCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWSPEED,
};

var protected const float MinLimit;
var protected config const float MaxLimit;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local float NewGameSpeed;

    if (ExecState.GetArgC() > 0)
    {
        NewGameSpeed = float(ExecState.GetArg(ECmdArgs.ARG_NEWSPEED));
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
        NewGameSpeed = float(ExecState.GetArg(ECmdArgs.ARG_NEWSPEED));

        if (!IsInRangeF(NewGameSpeed, MinLimit, MaxLimit))
        {
            return False;
        }
    }

    return True;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Game Speed set to "$ColorizeValue(KFGT.GameSpeed)$" by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "New Game Speed must be in range from "$MinLimit$" to "$MaxLimit;
}

defaultproperties
{
    MaxArgsNum=1
    ArgTypes(0)="number"

    MinLimit=0.25
    MaxLimit=10.0

    Aliases(0)="GS"
    Aliases(1)="GAMESPEED"
    Aliases(2)="SLOMO"
    Description="Set game speed"
    Signature="<? float GameSpeed>"

    bAdminOnly=True
}
