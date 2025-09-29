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
protected function bool ShouldBeTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    return True;
}

/****************************
 *  TARGET VERIFICATION
 *  (Used in ::CheckTargets)
 ****************************/

protected function bool VerifyTargetBySender(N7_CommandExecutionState ExecState, out string TargetName)
{
    TargetName = ExecState.GetSender().PlayerReplicationInfo.PlayerName;
    
    return ValidateTarget(ExecState, ExecState.GetSender());
}

protected function bool VerifyTargetByName(N7_CommandExecutionState ExecState, out string TargetName)
{
    local PlayerController Target;

    if (bAllowTargetAll && TargetName ~= "all")
    {
        return True;
    }

    Target = FindTarget(TargetName);

    if (Target != None)
    {
        TargetName = Target.PlayerReplicationInfo.PlayerName;
    }
    else
    {
        return False;
    }

    return ValidateTarget(ExecState, Target);
}

/****************************
 *  TARGET FILTERING
 *  (Used in ::ShouldBeTarget)
 ****************************/

protected function bool AcceptTargetBySender(N7_CommandExecutionState ExecState, PlayerController Target)
{
    return Target == ExecState.GetSender() && ValidateTarget(ExecState, Target);
}

protected function bool AcceptTargetByName(N7_CommandExecutionState ExecState, PlayerController Target, string TargetName)
{
    if (bAllowTargetAll && TargetName ~= "all" && ValidateTarget(ExecState, Target))
    {
        return True;
    }
    else if (ValidateTarget(ExecState, Target) && TargetName ~= Target.PlayerReplicationInfo.PlayerName)
    {
        if (bOnlyFirstTargetMatch)
        {
            ExecState.StopTargetSearch();
        }
        
        return True;
    }

    return False;
}

/****************************
 *  TARGET VALIDATION
 ****************************/

protected final function bool ValidateTarget(N7_CommandExecutionState ExecState, PlayerController Target)
{
    return CheckTargetReplicationInfo(ExecState, Target)
        && CheckTargetSelf(ExecState, Target)
        && CheckTargetAdmin(ExecState, Target)
        && CheckTargetSpectator(ExecState, Target)
        && CheckTargetHealth(ExecState, Target)
        && CheckTargetCustom(ExecState, Target);
}

protected final function bool CheckTargetReplicationInfo(N7_CommandExecutionState ExecState, PlayerController Target)
{
    return Target.PlayerReplicationInfo != None && !IsWebAdmin(Target);
}

protected final function bool CheckTargetSelf(N7_CommandExecutionState ExecState, PlayerController Target)
{
    return Target != ExecState.GetSender() || bAllowTargetSelf;
}

protected final function bool CheckTargetAdmin(N7_CommandExecutionState ExecState, PlayerController Target)
{
    return bOnlyNonAdminTargets && !IsAdmin(Target) || bOnlyAdminTargets && IsAdmin(Target) || !bOnlyAdminTargets && !bOnlyNonAdminTargets;
}

protected final function bool CheckTargetSpectator(N7_CommandExecutionState ExecState, PlayerController Target)
{
    return bOnlyPlayerTargets && !IsSpectator(Target) || bOnlySpectatorTargets && IsSpectator(Target) || !bOnlyPlayerTargets && !bOnlySpectatorTargets;
}

protected final function bool CheckTargetHealth(N7_CommandExecutionState ExecState, PlayerController Target)
{
    return bOnlyAliveTargets && IsAlive(Target) || bOnlyDeadTargets && !IsAlive(Target) || !bOnlyAliveTargets && !bOnlyDeadTargets;
}

protected function bool CheckTargetCustom(N7_CommandExecutionState ExecState, PlayerController Target)
{
    return True;
}

/****************************
 *  TARGET UTILS
 ****************************/

protected function SaveTarget(N7_CommandExecutionState ExecState, string TargetName)
{
    if (bOnlyFirstTargetMatch)
    {
        ExecState.SavePrimaryTarget(TargetName);
    }
}

protected function SaveSecondaryTarget(N7_CommandExecutionState ExecState, string TargetName)
{
    ExecState.SaveSecondaryTarget(TargetName);
}

protected function string LoadTarget(N7_CommandExecutionState ExecState)
{
    return ExecState.LoadPrimaryTarget();
}

protected function string LoadSecondaryTarget(N7_CommandExecutionState ExecState)
{
    return ExecState.LoadSecondaryTarget();
}

protected function PlayerController FindTarget(string TargetName)
{
    local Controller C;
    local PlayerController NearestTargetPC;
    local float CurrentMatchRatio, NearestTargetMatchRatio;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (IsPlayer(C))
        {
            CurrentMatchRatio = GetStringMatchRatio(TargetName, C.PlayerReplicationInfo.PlayerName);
    
            if (CurrentMatchRatio > NearestTargetMatchRatio)
            {
                NearestTargetMatchRatio = CurrentMatchRatio;
                NearestTargetPC = PlayerController(C);
            }
        }
    }

    return NearestTargetPC;
}

defaultproperties
{
    bNotifySenderOnSuccess=False
    bNotifyTargetsOnSuccess=True

    bUseTargets=True
    bAllowTargetAll=True
    bAllowTargetSelf=True
    bOnlyFirstTargetMatch=True
    bOnlyAliveTargets=False
    bOnlyDeadTargets=False
    bOnlyPlayerTargets=True
    bOnlySpectatorTargets=False
    bOnlyAdminTargets=False
    bOnlyNonAdminTargets=False
}
