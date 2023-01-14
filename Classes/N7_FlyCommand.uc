class N7_FlyCommand extends N7_MovementModeCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    PC.Pawn.bAmbientCreature = False;
    PC.Pawn.UnderWaterTime = PC.Pawn.default.UnderWaterTime;
    PC.Pawn.SetCollision(True, True, True);
    PC.Pawn.bCollideWorld = True;
    PC.GotoState('PlayerFlying');
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players are in flying mode";
    }

    return "You are in flying mode";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players are in flying mode";
    }

    return ColorizeTarget(TargetName)$" is in flying mode";
}

defaultproperties
{
    Aliases(0)="FLY"
    Description="Enable Flying mode"
}
