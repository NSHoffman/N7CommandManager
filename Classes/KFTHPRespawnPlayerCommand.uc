class KFTHPRespawnPlayerCommand extends KFTHPUnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    local bool bWaveInProgress;
    bWaveInProgress = Invasion(Level.Game).bWaveInProgress;

    PC.PlayerReplicationInfo.bOutOfLives = false;
    PC.PlayerReplicationInfo.NumLives = 0;

    PC.PlayerReplicationInfo.Score = Max(KFGT.MinRespawnCash, int(PC.PlayerReplicationInfo.Score));

    PC.GotoState('PlayerWaiting');
    PC.SetViewTarget(PC);
    PC.ClientSetBehindView(false);
    PC.bBehindView = false;
    PC.ClientSetViewTarget(PC.Pawn);

    if (bWaveInProgress)
    {
        Invasion(Level.Game).bWaveInProgress = false;
    }
    PC.ServerRestartPlayer();

    if (bWaveInProgress)
    {
        Invasion(Level.Game).bWaveInProgress = bWaveInProgress;
    }
}

/** @Override */
protected function bool ShouldBeTarget(
    KFTHPCommandExecutionState ExecState, 
    PlayerController PC)
{
    local string TargetName;
    
    switch (ExecState.GetArgC())
    {
        case 0:
            return PC == ExecState.GetSender();

        case 1:
            TargetName = ExecState.GetArg(ECmdArgs.ARG_TARGETNAME);

            if (IsStringPartOf(TargetName, PC.PlayerReplicationInfo.PlayerName))
            {
                ExecState.StopTargetSearch();
                
                return true;
            }
    }
    return false;
}

/** @Override */
protected function bool CheckGameState(KFTHPCommandExecutionState ExecState)
{
    if (KFGT.IsInState('MatchInProgress'))
    {
        return true;
    }

    return false;
}

/** @Override */
protected function bool CheckTargets(KFTHPCommandExecutionState ExecState)
{
    local PlayerController Target;
    local string TargetName;

    switch (ExecState.GetArgC())
    {
        case 0:
            KFTHPCommandPreservingState(ExecState).SaveString(
                ExecState.GetSender().PlayerReplicationInfo.PlayerName
            );
            return !IsAlive(ExecState.GetSender());

        case 1:
            TargetName = ExecState.GetArg(ECmdArgs.ARG_TARGETNAME);
            KFTHPCommandPreservingState(ExecState).SaveString(TargetName);

            if (TargetName ~= "all")
            {
                return true;
            }

            Target = FindTarget(TargetName);
            if (Target != None && !IsAlive(Target))
            {
                KFTHPCommandPreservingState(ExecState).SaveString(Target.PlayerReplicationInfo.PlayerName);
                return true;
            }
    }
    return false;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Players can be respawned only during the game";
}

/** @Override */
protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return "Only dead players can be respawned";
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = KFTHPCommandPreservingState(ExecState).LoadString();

    return "You have been respawned";
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = KFTHPCommandPreservingState(ExecState).LoadString();

    return TargetName$" has been respawned";
}

defaultproperties
{
    bAdminOnly=true
    Aliases(0)="RP"
    Aliases(1)="RESPAWN"
    Description="Respawn Player"
    Signature="<optional string TargetName>"
    bNotifyGlobalOnSuccess=true
}