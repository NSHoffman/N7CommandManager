/**
 * This class provides common logic for target based commands 
 * that accept only one optional target argument
 * (or in some cases there can be more arguments given that target argument is the first one)
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
    local string TargetName;
    local bool bValidTarget;

    switch (ExecState.GetArgC())
    {
        case 0:
            bValidTarget = VerifyTargetBySender(ExecState, TargetName);
            break;

        case 1:
        default:
            TargetName = ExecState.GetArg(ECmdArgs.ARG_TARGETNAME);
            bValidTarget = VerifyTargetByName(ExecState, TargetName);
            break;
    }

    SaveTarget(ExecState, TargetName);
    return bValidTarget;
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
            return AcceptTargetBySender(ExecState, PC, TargetName);

        case 1:
        default:
            TargetName = ExecState.GetArg(ECmdArgs.ARG_TARGETNAME);
            return AcceptTargetByName(ExecState, PC, TargetName);
    }

    return false;
}

/** @Override */
protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return LoadTarget(ExecState)$" is not a valid target";
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=1
    ArgTypes(0)="any"
    Signature="<? (string TargetName | 'all')>"
}
