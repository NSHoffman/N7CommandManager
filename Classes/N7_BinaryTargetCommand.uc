/**
 * This class provides common logic for commands that accept two arguments:
 * A value that is going to be applied somehow and optional target
 */
class N7_BinaryTargetCommand extends N7_TargetCommand
    abstract;

enum ECmdArgs
{
    ARG_VALUE,
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
        case 1:
            bValidTarget = VerifyTargetBySender(ExecState, TargetName);
            break;

        case 2:
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
        case 1:
            return AcceptTargetBySender(ExecState, PC);

        case 2:
        default:
            return AcceptTargetByName(ExecState, PC, LoadTarget(ExecState));
    }

    return False;
}

/** @Override */
protected function string InvalidTargetMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    TargetName = ColorizeTarget(LoadTarget(ExecState));
    
    return TargetName$" is not a valid target";
}

defaultproperties
{
    MaxArgsNum=2
    ArgTypes(0)="number"
    ArgTypes(1)="any"
}
