class N7_SpiderCommand extends N7_MovementModeCommand;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    PC.Pawn.bAmbientCreature = False;
    PC.Pawn.UnderWaterTime = PC.Pawn.default.UnderWaterTime;
    PC.Pawn.SetCollision(True, True, True);
    PC.Pawn.bCollideWorld = True;
    PC.GotoState('PlayerSpidering');
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;

    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players are in spider mode";
    }

    return "You are in spider mode";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;

    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players are in spider mode";
    }

    return ColorizeTarget(TargetName)$" is in spider mode";
}

defaultproperties
{
    Aliases(0)="SPIDER"
    Description="Enable spider mode"
}
