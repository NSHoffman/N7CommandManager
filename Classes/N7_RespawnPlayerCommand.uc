class N7_RespawnPlayerCommand extends N7_UnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    local bool bWaveInProgress;
    bWaveInProgress = Invasion(Level.Game).bWaveInProgress;

    PC.PlayerReplicationInfo.bOutOfLives = False;
    PC.PlayerReplicationInfo.NumLives = 0;

    PC.PlayerReplicationInfo.Score = Max(KFGT.MinRespawnCash, int(PC.PlayerReplicationInfo.Score));

    PC.GotoState('PlayerWaiting');
    PC.SetViewTarget(PC);
    PC.ClientSetBehindView(False);
    PC.bBehindView = False;
    PC.ClientSetViewTarget(PC.Pawn);

    if (bWaveInProgress)
    {
        Invasion(Level.Game).bWaveInProgress = False;
    }
    PC.ServerRestartPlayer();

    if (bWaveInProgress)
    {
        Invasion(Level.Game).bWaveInProgress = bWaveInProgress;
    }
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Players can be respawned only during the game";
}

/** @Override */
protected function string InvalidTargetMessage(N7_CommandExecutionState ExecState)
{
    return "Only dead players can be respawned";
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "You have been respawned";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players have been respawned";
    }

    return ColorizeTarget(TargetName)$" has been respawned";
}

defaultproperties
{
    Aliases(0)="RP"
    Aliases(1)="RESPAWN"
    Description="Respawn Player"
    Signature="<? (string TargetName | 'all')>"
    bOnlyDeadTargets=True
    bNotifyGlobalOnSuccess=True
}
