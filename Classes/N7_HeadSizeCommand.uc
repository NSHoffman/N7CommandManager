class N7_HeadSizeCommand extends N7_SizeCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    PC.Pawn.HeadScale = N7_CommandPreservedState(ExecState).LoadNumberF();
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    local float NewHeadScale;

    TargetName = LoadTarget(ExecState);
    NewHeadScale = N7_CommandPreservedState(ExecState).LoadNumberF();

    return "Your head size scale is set to "$NewHeadScale;
}

/** @Override */
protected function string GetSenderSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    local float NewHeadScale;

    TargetName = LoadTarget(ExecState);
    NewHeadScale = N7_CommandPreservedState(ExecState).LoadNumberF();

    if (TargetName ~= "all")
    {
        return "All players' heads size scale is set to "$NewHeadScale;
    }
    else if (TargetName ~= ExecState.GetSender().PlayerReplicationInfo.PlayerName)
    {
        return "Your head size scale is set to "$NewHeadScale;
    } 

    return TargetName$"'s head size scale is set to "$NewHeadScale;
}

defaultproperties
{
    bAdminOnly=true
    Aliases(0)="HEAD"
    Aliases(1)="HEADSIZE"
    Signature="<? float HeadScale, ? (string TargetName | 'all')>"
    Description="Set Player's head size scale"
    bNotifySenderOnSuccess=true
}
