class N7_SetPlayerArmorCommand extends N7_BinaryTargetCommand;

var protected const int MinLimit;
var protected const config int MaxLimit;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    local int NewShieldStrength;

    NewShieldStrength = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));
    NewShieldStrength = Clamp(NewShieldStrength, MinLimit, MaxLimit);

    PC.Pawn.ShieldStrength = NewShieldStrength;
    ExecState.SaveNumber(NewShieldStrength);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Armor can be set only during the game";
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, NewShieldStrength;

    TargetName = LoadTarget(ExecState);
    NewShieldStrength = ColorizeValue(ExecState.LoadNumber());

    if (TargetName ~= "all")
    {
        return "All players' armor has been set to " $ NewShieldStrength;
    }

    return "Your armor has been set to " $ NewShieldStrength;
}

defaultproperties
{
    MinArgsNum=1

    MinLimit=0
    MaxLimit=100

    Aliases(0)="SAR"
    Aliases(1)="SETARMOR"
    Description="Set player's armor"
    Signature="<int Armor, ? (string TargetName | 'all')>"

    bOnlyAliveTargets=True

    bAdminOnly=True
}
