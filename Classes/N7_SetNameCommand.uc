class N7_SetNameCommand extends N7_BinaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    PC.PlayerReplicationInfo.PlayerName = ExecState.GetArg(ECmdArgs.ARG_VALUE);
}

/** @Override */
protected function bool CheckIfNonAdminExecutionAllowed(N7_CommandExecutionState ExecState)
{
    return ExecState.GetArgC() == 1 
        || IsStringPartOf(ExecState.GetArg(ECmdArgs.ARG_TARGETNAME), ExecState.GetSender().PlayerReplicationInfo.PlayerName);
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string NewName;
    NewName = ColorizeValue(ExecState.GetArg(ECmdArgs.ARG_VALUE));

    return "Your name has been changed to "$NewName;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string OldName, NewName;
    
    OldName = ColorizeTarget(LoadTarget(ExecState));
    NewName = ColorizeValue(ExecState.GetArg(ECmdArgs.ARG_VALUE));

    return OldName$"'s name has been changed to "$NewName;
}

defaultproperties
{
    Aliases(0)="CN"
    Aliases(1)="SN"
    Aliases(2)="SETNAME"
    MinArgsNum=1
    MaxArgsNum=2
    ArgTypes(0)="any"
    ArgTypes(1)="any"
    Signature="<string Name, adminonly ? string TargetName>"
    Description="Change Player's name. Admin access allows for changing other players names"
    bNotifyGlobalOnSuccess=True
    bOnlyPlayerSender=False
    bAllowTargetAll=False
}
