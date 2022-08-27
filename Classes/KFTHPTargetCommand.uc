/**
 * This class provides common logic for commands
 * that are supposed to affect a selection of players
 */
class KFTHPTargetCommand extends KFTHPCommand
    abstract;

var protected config const bool bAllowTargetAll;
var protected config const bool bOnlyAliveTargets;
var protected config const bool bOnlyDeadTargets;
var protected config const bool bOnlyFirstTargetMatch;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local int i;

    for (i = 0; i < ExecState.GetTargetsNum(); i++)
    {
        DoActionForSingleTarget(ExecState, ExecState.GetTarget(i));
    }
}

protected final function bool CheckTargetHealth(PlayerController Target)
{
    if (bOnlyAliveTargets && IsAlive(Target))
    {
        return true;
    }
    else if (bOnlyDeadTargets && !IsAlive(Target))
    {
        return true;
    }
    else if (!bOnlyAliveTargets && !bOnlyDeadTargets)
    {
        return true;
    }

    return false;
}

protected function bool CheckTargetBySender(
    PlayerController Sender, 
    out string TargetName)
{
    if (CheckTargetHealth(Sender))
    {
        TargetName = Sender.PlayerReplicationInfo.PlayerName;
        return true;
    }

    return false;
}

protected function bool CheckTargetByName(out string TargetName)
{
    local PlayerController Target;

    if (bAllowTargetAll && TargetName ~= "all" && CheckTargetHealth(Target))
    {
        return true;
    }

    Target = FindTarget(TargetName);
    if (Target != None && CheckTargetHealth(Target))
    {
        TargetName = Target.PlayerReplicationInfo.PlayerName;
        return true;
    }

    return false;
}

protected function bool AcceptTargetBySender(
    KFTHPCommandExecutionState ExecState,
    PlayerController Target,
    string TargetName)
{
    return Target == ExecState.GetSender() && CheckTargetHealth(Target);
}

protected function bool AcceptTargetByName(
    KFTHPCommandExecutionState ExecState,
    PlayerController Target,
    string TargetName)
{
    if (bAllowTargetAll && TargetName ~= "all" && CheckTargetHealth(Target))
    {
        return true;
    }
    else if (CheckTargetHealth(Target) && IsStringPartOf(TargetName, Target.PlayerReplicationInfo.PlayerName))
    {
        if (bOnlyFirstTargetMatch)
        {
            ExecState.StopTargetSearch();
        }
        
        return true;
    }

    return false;
}

protected function SaveTarget(KFTHPCommandExecutionState ExecState, string TargetName)
{
    if (bOnlyFirstTargetMatch)
    {
        KFTHPCommandPreservingState(ExecState).SaveString(TargetName);
    }
}

protected function string LoadTarget(KFTHPCommandExecutionState ExecState)
{
    return KFTHPCommandPreservingState(ExecState).LoadString();
}

/** @Override */
protected function bool ShouldBeTarget(
    KFTHPCommandExecutionState ExecState, 
    PlayerController PC)
{
    return true;
}

protected function PlayerController FindTarget(string TargetName)
{
    local Controller C;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (IsPlayer(C) && IsStringPartOf(TargetName, C.PlayerReplicationInfo.PlayerName))
        {
            return PlayerController(C);   
        }
    }

    return None;
}

defaultproperties
{
    bUseTargets=true
    bAllowTargetAll=true
    bOnlyAliveTargets=false
    bOnlyDeadTargets=false
    bOnlyFirstTargetMatch=true
    bNotifySenderOnSuccess=false
    bNotifyTargetsOnSuccess=true
    CommandStateClass=Class'KFTHPCommandPreservingState'
}
