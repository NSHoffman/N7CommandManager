/**
 * This class provides common logic for commands
 * that are supposed to affect a selection of players
 */
class N7_TargetCommand extends N7_Command
    abstract;

var protected const bool bAllowTargetAll;
var protected const bool bAllowTargetSelf;
var protected const bool bOnlyFirstTargetMatch;
var protected config const bool bOnlyAliveTargets;
var protected config const bool bOnlyDeadTargets;
var protected config const bool bOnlyPlayerTargets;
var protected config const bool bOnlySpectatorTargets;
var protected config const bool bOnlyAdminTargets;
var protected config const bool bOnlyNonAdminTargets;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int i;

    for (i = 0; i < ExecState.GetTargetsNum(); i++)
    {
        DoActionForSingleTarget(ExecState, ExecState.GetTarget(i));
    }
}

/** @Override */
protected function bool ShouldBeTarget(
    N7_CommandExecutionState ExecState, 
    PlayerController PC)
{
    return true;
}

/****************************
 *  TARGET VERIFICATION
 *  (Used in ::CheckTargets)
 ****************************/

protected function bool VerifyTargetBySender(
    N7_CommandExecutionState ExecState, out string TargetName)
{
    TargetName = ExecState.GetSender().PlayerReplicationInfo.PlayerName;
    
    return ValidateTarget(ExecState, ExecState.GetSender());
}

protected function bool VerifyTargetByName(
    N7_CommandExecutionState ExecState, out string TargetName)
{
    local PlayerController Target;

    if (bAllowTargetAll && TargetName ~= "all")
    {
        return true;
    }

    Target = FindTarget(TargetName);

    if (Target != None)
    {
        TargetName = Target.PlayerReplicationInfo.PlayerName;
    }
    else
    {
        return false;
    }

    return ValidateTarget(ExecState, Target);
}

/****************************
 *  TARGET FILTERING
 *  (Used in ::ShouldBeTarget)
 ****************************/

protected function bool AcceptTargetBySender(
    N7_CommandExecutionState ExecState,
    PlayerController Target,
    optional string TargetName)
{
    return Target == ExecState.GetSender() && ValidateTarget(ExecState, Target);
}

protected function bool AcceptTargetByName(
    N7_CommandExecutionState ExecState,
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
    N7_CommandExecutionState ExecState, PlayerController Target)
{
    return CheckTargetReplicationInfo(ExecState, Target)
        && CheckTargetSelf(ExecState, Target)
        && CheckTargetAdmin(ExecState, Target)
        && CheckTargetSpectator(ExecState, Target)
        && CheckTargetHealth(ExecState, Target)
        && CheckTargetCustom(ExecState, Target);
}

protected final function bool CheckTargetReplicationInfo(
    N7_CommandExecutionState ExecState, PlayerController Target)
{
    return Target.PlayerReplicationInfo != None && !IsWebAdmin(Target);
}

protected final function bool CheckTargetSelf(
    N7_CommandExecutionState ExecState, PlayerController Target)
{
    return Target != ExecState.GetSender() || bAllowTargetSelf;
}

protected final function bool CheckTargetAdmin(
    N7_CommandExecutionState ExecState, PlayerController Target)
{
    return bOnlyNonAdminTargets && !IsAdmin(Target)
        || bOnlyAdminTargets && IsAdmin(Target)
        || !bOnlyAdminTargets && !bOnlyNonAdminTargets;
}

protected final function bool CheckTargetSpectator(
    N7_CommandExecutionState ExecState, PlayerController Target)
{
    return bOnlyPlayerTargets && !IsSpectator(Target)
        || bOnlySpectatorTargets && IsSpectator(Target)
        || !bOnlyPlayerTargets && !bOnlySpectatorTargets;
}

protected final function bool CheckTargetHealth(
    N7_CommandExecutionState ExecState, PlayerController Target)
{
    return bOnlyAliveTargets && IsAlive(Target)
        || bOnlyDeadTargets && !IsAlive(Target)
        || !bOnlyAliveTargets && !bOnlyDeadTargets;
}

protected function bool CheckTargetCustom(
    N7_CommandExecutionState ExecState, PlayerController Target)
{
    return true;
}

/****************************
 *  TARGET UTILS
 ****************************/

protected function SaveTarget(
    N7_CommandExecutionState ExecState, string TargetName)
{
    if (bOnlyFirstTargetMatch)
    {
        ExecState.SaveTarget(TargetName);
    }
}

protected function string LoadTarget(N7_CommandExecutionState ExecState)
{
    return ExecState.LoadTarget();
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
    bOnlyAdminTargets=false
    bOnlyNonAdminTargets=false
    bOnlyFirstTargetMatch=true
    bNotifySenderOnSuccess=false
    bNotifyTargetsOnSuccess=true
}
