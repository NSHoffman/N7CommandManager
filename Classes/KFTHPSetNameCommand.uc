class KFTHPSetNameCommand extends KFTHPCommand;

enum ECmdArgs
{
    ARG_NAME,
};

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local string OldName, NewName;

    OldName = ExecState.GetSender().PlayerReplicationInfo.PlayerName;
    NewName = ExecState.GetArg(ECmdArgs.ARG_NAME);

    KFTHPCommandPreservingState(ExecState).SaveString(OldName);
    ExecState.GetSender().PlayerReplicationInfo.PlayerName = NewName;
}

/** @Override */
protected function bool ShouldNotifyGlobalOnSuccess()
{
    return true;
}

/** @Override */
protected function string GetSenderSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string NewName;
    
    NewName = ExecState.GetArg(ECmdArgs.ARG_NAME);

    return "Your name has been changed to "$NewName;
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string NewName;
    
    NewName = ExecState.GetArg(ECmdArgs.ARG_NAME);

    return KFTHPCommandPreservingState(ExecState).LoadString()$"'s name has been changed to "$NewName;
}

defaultproperties
{
    MinArgsNum=1
    MaxArgsNum=1
    Aliases(0)="CN"
    Aliases(1)="SN"
    Aliases(2)="SETNAME"
    ArgTypes(0)="any"
    Signature="<string Name>"
    Description="Set new name"
    CommandStateClass=Class'KFTHPCommandPreservingState'
}
