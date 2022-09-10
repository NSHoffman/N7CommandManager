class N7_GhostCommand extends N7_MovementModeCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    PC.Pawn.bAmbientCreature = true;
    PC.Pawn.UnderWaterTime = -1.0;
    PC.Pawn.SetCollision(false, false, false);
    PC.Pawn.bCollideWorld = false;
    PC.GotoState('PlayerFlying');
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players are in ghost mode";
    }

    return "You are in ghost mode";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players are in ghost mode";
    }

    return TargetName$" is in ghost mode";
}

defaultproperties
{
    Aliases(0)="GHOST"
    Description="Enable Ghost mode"
}
