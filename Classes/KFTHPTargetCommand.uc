/**
 * This class provides common logic for commands
 * that are supposed to affect a selection of players
 */
class KFTHPTargetCommand extends KFTHPCommand
    abstract;

var protected config const bool bAllowTargetAll;
var protected config const bool bAllowTargetSelf;
var protected config const bool bOnlyAliveTargets;
var protected config const bool bOnlyDeadTargets;
var protected config const bool bOnlyFirstTargetMatch;
var protected config const bool bOnlyPlayerTargets;
var protected config const bool bOnlySpectatorTargets;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local int i;

    for (i = 0; i < ExecState.GetTargetsNum(); i++)
    {
        DoActionForSingleTarget(ExecState, ExecState.GetTarget(i));
    }
}

/** @Override */
protected function bool ShouldBeTarget(
    KFTHPCommandExecutionState ExecState, 
    PlayerController PC)
{
    return true;
}

/****************************
 *  TARGET VERIFICATION
 *  (Used in ::CheckTargets)
 ****************************/

protected function bool VerifyTargetBySender(
    KFTHPCommandExecutionState ExecState, out string TargetName)
{
    if (ValidateTarget(ExecState, ExecState.GetSender()))
    {
        TargetName = ExecState.GetSender().PlayerReplicationInfo.PlayerName;
        return true;
    }

    return false;
}

protected function bool VerifyTargetByName(
    KFTHPCommandExecutionState ExecState, out string TargetName)
{
    local PlayerController Target;

    if (bAllowTargetAll && TargetName ~= "all")
    {
        return true;
    }

    Target = FindTarget(TargetName);
    if (Target != None && ValidateTarget(ExecState, Target))
    {
        TargetName = Target.PlayerReplicationInfo.PlayerName;
        return true;
    }

    return false;
}

/****************************
 *  TARGET FILTERING
 *  (Used in ::ShouldBeTarget)
 ****************************/

protected function bool AcceptTargetBySender(
    KFTHPCommandExecutionState ExecState,
    PlayerController Target,
    optional string TargetName)
{
    return Target == ExecState.GetSender() && ValidateTarget(ExecState, Target);
}

protected function bool AcceptTargetByName(
    KFTHPCommandExecutionState ExecState,
    PlayerController Target,
    string TargetName)
{
    if (bAllowTargetAll && TargetName ~= "all" && ValidateTarget(ExecState, Target))
    {
        return true;
    }
    else if (ValidateTarget(ExecState, Target) && IsStringPartOf(TargetName, Target.PlayerReplicationInfo.PlayerName))
    {
        if (bOnlyFirstTargetMatch)
        {
            ExecState.StopTargetSearch();
        }
        
        return true;
    }

    return false;
}

/****************************
 *  TARGET VALIDATION
 ****************************/

protected final function bool ValidateTarget(
    KFTHPCommandExecutionState ExecState, PlayerController Target)
{
    if (!CheckTargetReplicationInfo(ExecState, Target))
    {
        return false;
    }

    if (!CheckTargetSelf(ExecState, Target))
    {
        return false;
    }

    if (!CheckTargetRole(ExecState, Target))
    {
        return false;
    }

    if (!CheckTargetHealth(ExecState, Target))
    {
        return false;
    }

    if (!CheckTargetCustom(ExecState, Target))
    {
        return false;
    }

    return true;
}

protected final function bool CheckTargetReplicationInfo(
    KFTHPCommandExecutionState ExecState, PlayerController Target)
{
    return Target.PlayerReplicationInfo != None && !IsWebAdmin(Target);
}

protected final function bool CheckTargetSelf(
    KFTHPCommandExecutionState ExecState, PlayerController Target)
{
    return Target != ExecState.GetSender() || bAllowTargetSelf;
}

protected final function bool CheckTargetRole(
    KFTHPCommandExecutionState ExecState, PlayerController Target)
{
    if (bOnlyPlayerTargets && !IsSpectator(Target))
    {
        return true;
    }
    else if (bOnlySpectatorTargets && IsSpectator(Target))
    {
        return true;
    }
    else if (!bOnlyPlayerTargets && !bOnlySpectatorTargets)
    {
        return true;
    }

    return false;
}

protected final function bool CheckTargetHealth(
    KFTHPCommandExecutionState ExecState, PlayerController Target)
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

protected function bool CheckTargetCustom(
    KFTHPCommandExecutionState ExecState, PlayerController Target)
{
    return true;
}

/****************************
 *  TARGET UTILS
 ****************************/

protected function SaveTarget(
    KFTHPCommandExecutionState ExecState, string TargetName)
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
    bAllowTargetSelf=true
    bOnlyAliveTargets=false
    bOnlyDeadTargets=false
    bOnlyPlayerTargets=true
    bOnlySpectatorTargets=false
    bOnlyFirstTargetMatch=true
    bNotifySenderOnSuccess=false
    bNotifyTargetsOnSuccess=true
    CommandStateClass=Class'KFTHPCommandPreservingState'
}
