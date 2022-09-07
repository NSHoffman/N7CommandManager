class KFTHPForceSpectatorCommand extends KFTHPUnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    PC.PlayerReplicationInfo.bOnlySpectator = true;
    KFGT.NumSpectators++;
    KFGT.NumPlayers--;

    if (PC.Pawn != None)
    {
        PC.Pawn.Died(PC, class'DamageType', PC.Pawn.Location);
    }

    if (PC.PlayerReplicationInfo.Team != None)
    {
        PC.PlayerReplicationInfo.Team.RemoveFromTeam(PC);
    }
    PC.PlayerReplicationInfo.Team = None;
    PC.PlayerReplicationInfo.Score = 0;
    PC.PlayerReplicationInfo.Deaths = 0;
    PC.PlayerReplicationInfo.GoalsScored = 0;
    PC.PlayerReplicationInfo.Kills = 0;
    
    PC.ServerSpectate();
    PC.ClientBecameSpectator();
}

/** @Override */
protected function bool CheckTargetCustom(
    KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    return PC.PlayerReplicationInfo != None
        && KFGT.NumSpectators < KFGT.MaxSpectators 
        && !PC.IsInState('GameEnded') 
        && !PC.IsInState('RoundEnded');
}

/** @Override */
protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return "Invalid target "$LoadTarget(ExecState)$" or spectators limit reached";
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "You have been forced to become a spectator";
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    return TargetName$" has been forced to become a spectator";
}

defaultproperties
{
    bAdminOnly=true
    Aliases(0)="FSPEC"
    Aliases(1)="FORCESPEC"
    Description="Force player to become a spectator"
    Signature="<? string TargetName>"
    bAllowTargetAll=false
    bOnlyNonAdminTargets=true
    bNotifyGlobalOnSuccess=true
}
