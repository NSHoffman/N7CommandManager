class KFTHPSpiderCommand extends KFTHPMovementModeCommand;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    PC.Pawn.bAmbientCreature = false;
    PC.Pawn.UnderWaterTime = PC.Pawn.Default.UnderWaterTime;
    PC.Pawn.SetCollision(true, true, true);
    PC.Pawn.bCollideWorld = true;
    PC.GotoState('PlayerSpidering');
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
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
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players are in spider mode";
    }

    return TargetName$" is in spider mode";
}

defaultproperties
{
    Aliases(0)="SPIDER"
    Description="Enable Spider mode"
}
