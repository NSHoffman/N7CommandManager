class N7_WalkCommand extends N7_MovementModeCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    PC.Pawn.bAmbientCreature = false;
    PC.Pawn.UnderWaterTime = PC.Pawn.default.UnderWaterTime;
    PC.Pawn.SetCollision(true, true, true);
    PC.Pawn.SetPhysics(PHYS_Walking);
    PC.Pawn.bCollideWorld = true;
    PC.Pawn.bCanJump = true;
    PC.GotoState('PlayerWalking');
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players are in walking mode";
    }

    return "You are in walking mode";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players are in walking mode";
    }

    return ColorizeTarget(TargetName)$" is in walking mode";
}

defaultproperties
{
    Aliases(0)="WALK"
    Description="Enable Walking mode"
}
