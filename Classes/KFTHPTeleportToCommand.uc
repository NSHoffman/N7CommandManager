class KFTHPTeleportToCommand extends KFTHPTargetCommand;

enum ECmdArgs
{
    ARG_TARGETNAME,
};

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    local Vector TpLocation;

    TpLocation = PC.Pawn.Location;
    ExecState.GetSender().ViewTarget.SetLocation(TpLocation + 72 * Vector(ExecState.GetSender().Rotation) + vect(0, 0, 1) * 15);
    ExecState.GetSender().ViewTarget.PlayTeleportEffect(false, true);
}

/** @Override */
protected function bool CheckTargets(KFTHPCommandExecutionState ExecState)
{
    local PlayerController Target;
    local string TargetName;

    TargetName = ExecState.GetArg(ECmdArgs.ARG_TARGETNAME);
    KFTHPCommandPreservingState(ExecState).SaveString(TargetName);

    Target = FindTarget(TargetName);
    if (Target != None && IsAlive(Target))
    {
        KFTHPCommandPreservingState(ExecState).SaveString(Target.PlayerReplicationInfo.PlayerName);
        return true;
    }

    return false;
}

/** @Override */
protected function bool ShouldBeTarget(
    KFTHPCommandExecutionState ExecState, 
    PlayerController PC)
{
    local string TargetName;
    
    TargetName = ExecState.GetArg(ECmdArgs.ARG_TARGETNAME);

    if (IsStringPartOf(TargetName, PC.PlayerReplicationInfo.PlayerName))
    {
        ExecState.StopTargetSearch();
        
        return true;
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
protected function string InvalidGameStateMessage()
{
    return "You can teleport only during the game";
}

/** @Override */
protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return "Cannot find alive player with name "$KFTHPCommandPreservingState(ExecState).LoadString();
}

defaultproperties
{
    bAdminOnly=true
    MinArgsNum=1
    MaxArgsNum=1
    Aliases(0)="TPT"
    Aliases(1)="TELEPORTP"
    ArgTypes(0)="any"
    Signature="<string TargetName>"
    Description="Teleport to another player"
    CommandStateClass=Class'KFTHPCommandPreservingState'
    bNotifySenderOnSuccess=false
}
