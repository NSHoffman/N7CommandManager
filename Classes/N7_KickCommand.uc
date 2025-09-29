class N7_KickCommand extends N7_UnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
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
protected function bool CheckTargetCustom(N7_CommandExecutionState ExecState, PlayerController Target)
{
    return NetConnection(Target.Player) != None;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = ColorizeTarget(LoadTarget(ExecState));

    return TargetName$" was kicked";
}

defaultproperties
{
    MinArgsNum=1

    Aliases(0)="KICK"
    Description="Kick player"
    Signature="<string TargetName>"

    bNotifyTargetsOnSuccess=False
    bNotifyGlobalOnSuccess=True

    bAllowTargetAll=False
    bOnlyPlayerTargets=False
    bOnlyNonAdminTargets=True

    bAdminOnly=True
}
