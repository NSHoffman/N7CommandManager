class N7_BoostCommand extends N7_BinaryTargetCommand;

var protected const int MinLimit;
var protected const config int MaxLimit; 

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    if (int(ExecState.GetArg(ECmdArgs.ARG_VALUE)) != PC.Pawn.default.HealthMax)
    {
        PC.Pawn.Health = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));
        ExecState.SaveFlag(True);
    }
    else
    {
        PC.Pawn.Health = PC.Pawn.default.HealthMax;
        ExecState.SaveFlag(False);
    }
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return !KFGT.IsInState('PendingMatch');
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int NewHealth;
    NewHealth = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));

    if (!IsInRange(NewHealth, MinLimit, MaxLimit))
    {
        return False; 
    }

    return True;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Players can be boosted only during the game";
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Boosted health must be in range from "$MinLimit$" to "$MaxLimit;
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, BoostState;

    TargetName = LoadTarget(ExecState);

    if (ExecState.LoadFlag())
    {
        BoostState = ColorizeValue("boosted");
    }
    else
    {
        BoostState = ColorizeValue("reset back to normal");
    }

    if (TargetName ~= "all")
    {
        return "All players' HP and speed "$BoostState;
    }

    return "Your HP and speed "$BoostState;
}

defaultproperties
{
    MinArgsNum=1

    MinLimit=100
    MaxLimit=1500

    Aliases(0)="BOOST"
    Description="Boost HP and speed"
    Signature="<int Health, ? (string TargetName | 'all')>"

    bOnlyAliveTargets=True

    bAdminOnly=True
}
