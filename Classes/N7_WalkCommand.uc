class N7_WalkCommand extends N7_MovementModeCommand;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    PC.Pawn.bAmbientCreature = False;
    PC.Pawn.UnderWaterTime = PC.Pawn.default.UnderWaterTime;
    PC.Pawn.SetCollision(True, True, True);
    PC.Pawn.SetPhysics(PHYS_Walking);
    PC.Pawn.bCollideWorld = True;
    PC.Pawn.bCanJump = True;
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
    Description="Enable walking mode"
}
