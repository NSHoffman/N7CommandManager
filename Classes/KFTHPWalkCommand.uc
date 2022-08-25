class KFTHPWalkCommand extends KFTHPMovementModeCommand;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    PC.Pawn.bAmbientCreature = false;
    PC.Pawn.UnderWaterTime = PC.Pawn.Default.UnderWaterTime;
    PC.Pawn.SetCollision(true, true, true);
    PC.Pawn.SetPhysics(PHYS_Walking);
    PC.Pawn.bCollideWorld = true;
    PC.Pawn.bCanJump = true;
    PC.GotoState('PlayerWalking');
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = KFTHPCommandPreservingState(ExecState).LoadString();

    if (TargetName ~= "all")
    {
        return "All players are in walking mode";
    }

    return "You are in walking mode";
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = KFTHPCommandPreservingState(ExecState).LoadString();

    if (TargetName ~= "all")
    {
        return "All players are in walking mode";
    }

    return TargetName$" is in walking mode";
}

defaultproperties
{
    Aliases(0)="WALK"
    Description="Enable Walking mode"
}
