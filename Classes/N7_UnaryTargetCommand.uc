/**
 * This class provides common logic for target based commands 
 * that accept only one optional target argument
 * (or in some cases there can be more arguments given that target argument is the first one)
 */
class N7_UnaryTargetCommand extends N7_TargetCommand
    abstract;

enum ECmdArgs
{
    ARG_TARGETNAME,
};

/** @Override */
protected function bool CheckTargets(N7_CommandExecutionState ExecState)
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
protected function bool ShouldBeTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    switch (ExecState.GetArgC())
    {
        case 0:
            return AcceptTargetBySender(ExecState, PC);

        case 1:
        default:
            return AcceptTargetByName(ExecState, PC, LoadTarget(ExecState));
    }

    return False;
}

/** @Override */
protected function string InvalidTargetMessage(N7_CommandExecutionState ExecState)
{
    return ColorizeTarget(LoadTarget(ExecState))$" is not a valid target";
}

defaultproperties
{
    MaxArgsNum=1
    ArgTypes(0)="any"

    Signature="<? (string TargetName | 'all')>"
}
