class N7_SetPlayerHealthCommand extends N7_BinaryTargetCommand;

var protected const int MinLimit;
var protected const config int MaxLimit;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    local int NewHealth;

    NewHealth = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));
    NewHealth = Clamp(NewHealth, MinLimit, MaxLimit);

    PC.Pawn.Health = NewHealth;
    ExecState.SaveNumber(NewHealth);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Health can be set only during the game";
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, NewHealth;

    TargetName = LoadTarget(ExecState);
    NewHealth = ColorizeValue(ExecState.LoadNumber());


    if (TargetName ~= "all")
    {
        return "All players' health has been set to " $ NewHealth;
    }

    return "Your health has been set to " $ NewHealth;
}

defaultproperties
{
    MinArgsNum=1

    MinLimit=1
    MaxLimit=500

    Aliases(0)="SH"
    Aliases(1)="SETHEALTH"
    Description="Set player's health"
    Signature="<int Health, ? (string TargetName | 'all')>"

    bOnlyAliveTargets=True

    bAdminOnly=True
}
