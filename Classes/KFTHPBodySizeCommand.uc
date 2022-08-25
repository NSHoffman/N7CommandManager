class KFTHPBodySizeCommand extends KFTHPSizeCommand;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    local float NewBodyScale;
    NewBodyScale = KFTHPCommandPreservingState(ExecState).LoadNumberF();

    PC.Pawn.SetDrawScale(PC.Pawn.Default.DrawScale * NewBodyScale);
    PC.Pawn.SetCollisionSize(
        PC.Pawn.Default.CollisionRadius * NewBodyScale, 
        PC.Pawn.Default.CollisionHeight * NewBodyScale
    );
    PC.Pawn.BaseEyeHeight = PC.Pawn.Default.BaseEyeHeight * NewBodyScale;
    PC.Pawn.EyeHeight = PC.Pawn.Default.EyeHeight * NewBodyScale;
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    local float NewBodyScale;

    TargetName = KFTHPCommandPreservingState(ExecState).LoadString();
    NewBodyScale = KFTHPCommandPreservingState(ExecState).LoadNumberF();

    return "Your body size scale is set to "$NewBodyScale;
}

/** @Override */
protected function string GetSenderSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    local float NewBodyScale;

    TargetName = KFTHPCommandPreservingState(ExecState).LoadString();
    NewBodyScale = KFTHPCommandPreservingState(ExecState).LoadNumberF();

    if (TargetName ~= "all")
    {
        return "All players' body size scale is set to "$NewBodyScale;
    } 
    else if (TargetName ~= ExecState.GetSender().PlayerReplicationInfo.PlayerName)
    {
        return "Your body size scale is set to "$NewBodyScale;
    } 

    return TargetName$"'s body size scale is set to "$NewBodyScale;
}

defaultproperties
{
    bAdminOnly=true
    Aliases(0)="BODY"
    Aliases(1)="BODYSIZE"
    Signature="float BodyScale, optional (string TargetName | 'all')>"
    Description="Set Player's body size scale"
    bNotifySenderOnSuccess=true
}
