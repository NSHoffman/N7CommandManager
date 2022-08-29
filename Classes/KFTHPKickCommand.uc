class KFTHPKickCommand extends KFTHPUnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    PC.ClientNetworkMessage("AC_Kicked", KFGT.AccessControl.DefaultKickReason);

    if (PC.Pawn != None && Vehicle(PC.Pawn) == None)
    {
        PC.Pawn.Destroy();
    }

    if (PC != None)
    {
        PC.Destroy();
    }
}

/** @Override */
protected function bool CheckTargetCustom(
    KFTHPCommandExecutionState ExecState, PlayerController Target)
{
    return NetConnection(Target.Player) != None;
}

/** @Override */
protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return "Cannot find valid targets with name "$LoadTarget(ExecState);
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = LoadTarget(ExecState);

    return TargetName$" was kicked";
}

defaultproperties
{
    bAdminOnly=true
    MinArgsNum=1
    MaxArgsNum=1
    Aliases(0)="KICK"
    Description="Kick Player"
    Signature="<string TargetName>"
    bAllowTargetAll=false
    bNotifyTargetsOnSuccess=false
    bNotifyGlobalOnSuccess=true
}
