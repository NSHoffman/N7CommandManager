/**
 * This class provides common logic for target based commands 
 * that accept only one optional target argument
 */
class KFTHPUnaryTargetCommand extends KFTHPTargetCommand
    abstract;

enum ECmdArgs
{
    ARG_TARGETNAME,
};

/** @Override */
protected function bool CheckTargets(KFTHPCommandExecutionState ExecState)
{
    local PlayerController Target;
    local string TargetName;

    switch (ExecState.GetArgC())
    {
        case 0:
            return true;

        case 1:
            TargetName = ExecState.GetArg(ECmdArgs.ARG_TARGETNAME);
            KFTHPCommandPreservingState(ExecState).SaveString(TargetName);

            if (TargetName ~= "all")
            {
                return true;
            }

            Target = FindTarget(TargetName);
            if (Target != None)
            {
                KFTHPCommandPreservingState(ExecState).SaveString(Target.PlayerReplicationInfo.PlayerName);
                return true;
            }
    }
    return false;
}

/** @Override */
protected function bool ShouldBeTarget(
    KFTHPCommandExecutionState ExecState, 
    PlayerController PC)
{
    local string TargetName;
    
    switch (ExecState.GetArgC())
    {
        case 0:
            return PC == ExecState.GetSender();

        case 1:
            TargetName = ExecState.GetArg(ECmdArgs.ARG_TARGETNAME);

            if (TargetName ~= "all")
            {
                return true;
            }
            else if (IsStringPartOf(TargetName, PC.PlayerReplicationInfo.PlayerName))
            {
                ExecState.StopTargetSearch();
                
                return true;
            }
    }
    return false;
}

/** @Override */
protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return "Cannot find player with name "$KFTHPCommandPreservingState(ExecState).LoadString();
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=1
    ArgTypes(0)="any"
    Signature="<optional (string TargetName | 'all')>"
    CommandStateClass=Class'KFTHPCommandPreservingState'
}
