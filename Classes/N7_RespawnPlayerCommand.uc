class N7_RespawnPlayerCommand extends N7_UnaryTargetCommand;

enum ECmdArgs_X
{
    ARG_TARGETNAME,
    ARG_SPAWNLOCATION,
};

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    local bool bWaveInProgress;
    local string SpawnTargetName;
    local Vector SpawnLocation;
    local Rotator SpawnRotation;
    local bool bHasSpawnLocation;

    bWaveInProgress = KFGT.bWaveInProgress;

    PC.PlayerReplicationInfo.bOutOfLives = False;
    PC.PlayerReplicationInfo.NumLives = 0;

    PC.PlayerReplicationInfo.Score = Max(KFGT.MinRespawnCash, int(PC.PlayerReplicationInfo.Score));

    if (ExecState.GetArgC() > 1)
    {
        SpawnTargetName = ExecState.GetArg(ECmdArgs_X.ARG_SPAWNLOCATION);
    }

    bHasSpawnLocation = GSU.GetPlayerSpawnLocation(SpawnTargetName, SpawnLocation, SpawnRotation);

    PC.GotoState('PlayerWaiting');
    PC.SetViewTarget(PC);
    PC.ClientSetBehindView(False);
    PC.bBehindView = False;
    PC.ClientSetViewTarget(PC.Pawn);

    if (bWaveInProgress)
    {
        KFGT.bWaveInProgress = False;
    }

    PC.ServerRestartPlayer();

    if (bWaveInProgress)
    {
        KFGT.bWaveInProgress = bWaveInProgress;
    }

    if (bHasSpawnLocation && PC.Pawn != None)
    {
        PC.Pawn.SetLocation(SpawnLocation);
        PC.Pawn.SetRotation(SpawnRotation);
        PC.SetRotation(SpawnRotation);
        PC.ClientSetLocation(SpawnLocation, SpawnRotation);
    }
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    if (ExecState.GetArgC() <= 1)
    {
        return True;
    }

    return GSU.GetPlayerSpawnLocation(ExecState.GetArg(ECmdArgs_X.ARG_SPAWNLOCATION));
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
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return ColorizeValue(ExecState.GetArg(ECmdArgs_X.ARG_SPAWNLOCATION))$" is not a valid player to spawn near";
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

/** @Override */
protected function ExtendedHelp(PlayerController PC)
{
    HelpSectionSeparator(PC, "Call Options");
    SendMessage(PC, "No arguments - Respawn self at map spawn point");
    SendMessage(PC, "One argument - Respawn target player at map spawn point");
    SendMessage(PC, "Two arguments - Respawn target player next to the other player");
}

defaultproperties
{
    MaxArgsNum=2
    ArgTypes(1)="any"

    Aliases(0)="RP"
    Aliases(1)="RESPAWN"
    Description="Respawn player"
    Signature="<? (string TargetName | 'all'), ? string SpawnNear>"

    bNotifyGlobalOnSuccess=True

    bOnlyDeadTargets=True
}
