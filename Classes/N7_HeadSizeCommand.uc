class N7_HeadSizeCommand extends N7_SizeCommand;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    PC.Pawn.HeadScale = ExecState.LoadNumberF();
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, NewHeadScale;

    TargetName = LoadTarget(ExecState);
    NewHeadScale = ColorizeValue(ExecState.LoadNumberF());

    if (TargetName ~= "all")
    {
        return "All players' heads size scale is set to "$NewHeadScale;
    }

    return "Your head size scale is set to "$NewHeadScale;
}

/** @Override */
protected function string GetSenderSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, NewHeadScale;

    TargetName = LoadTarget(ExecState);
    NewHeadScale = ColorizeValue(ExecState.LoadNumberF());

    if (TargetName ~= "all")
    {
        return "All players' heads size scale is set to "$NewHeadScale;
    }
    else if (TargetName ~= ExecState.GetSender().PlayerReplicationInfo.PlayerName)
    {
        return "Your head size scale is set to "$NewHeadScale;
    } 

    return ColorizeTarget(TargetName)$"'s head size scale is set to "$NewHeadScale;
}

defaultproperties
{
    Aliases(0)="HEAD"
    Aliases(1)="HEADSIZE"
    Description="Set player's head size scale"
    Signature="<? float HeadScale, ? (string TargetName | 'all')>"

    bAdminOnly=True
}
