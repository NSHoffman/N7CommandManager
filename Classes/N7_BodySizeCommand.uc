class N7_BodySizeCommand extends N7_SizeCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    local float NewBodyScale;
    NewBodyScale = ExecState.LoadNumberF();

    GSU.ResizePlayer(PC, NewBodyScale);
    if (NewBodyScale != 1.0)
    {
        AddResizedPlayer(PC, NewBodyScale);
    }
    else
    {
        RemoveResizedPlayer(PC);
    }
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, NewBodyScale;

    TargetName = LoadTarget(ExecState);
    NewBodyScale = ColorizeValue(ExecState.LoadNumberF());

    if (TargetName ~= "all")
    {
        return "All players' body size scale is set to "$NewBodyScale;
    } 

    return "Your body size scale is set to "$NewBodyScale;
}

/** @Override */
protected function string GetSenderSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, NewBodyScale;

    TargetName = LoadTarget(ExecState);
    NewBodyScale = ColorizeValue(ExecState.LoadNumberF());

    if (TargetName ~= "all")
    {
        return "All players' body size scale is set to "$NewBodyScale;
    } 
    else if (TargetName ~= ExecState.GetSender().PlayerReplicationInfo.PlayerName)
    {
        return "Your body size scale is set to "$NewBodyScale;
    } 

    return ColorizeTarget(TargetName)$"'s body size scale is set to "$NewBodyScale;
}

defaultproperties
{
    bAdminOnly=True
    Aliases(0)="BODY"
    Aliases(1)="BODYSIZE"
    Signature="<? float BodyScale, ? (string TargetName | 'all')>"
    Description="Set Player's body size scale"
}
