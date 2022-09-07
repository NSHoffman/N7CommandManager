class KFTHPHeadSizeCommand extends KFTHPSizeCommand;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    PC.Pawn.HeadScale = KFTHPCommandPreservedState(ExecState).LoadNumberF();
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    local float NewHeadScale;

    TargetName = LoadTarget(ExecState);
    NewHeadScale = KFTHPCommandPreservedState(ExecState).LoadNumberF();

    return "Your head size scale is set to "$NewHeadScale;
}

/** @Override */
protected function string GetSenderSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    local float NewHeadScale;

    TargetName = LoadTarget(ExecState);
    NewHeadScale = KFTHPCommandPreservedState(ExecState).LoadNumberF();

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
