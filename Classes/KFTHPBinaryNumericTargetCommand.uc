/**
 * This class provides common logic for commands that accept two arguments:
 * Numeric value that is going to be applied somehow and optional target
 */
class KFTHPBinaryNumericTargetCommand extends KFTHPTargetCommand
    abstract;

enum ECmdArgs
{
    ARG_NUMBER,
    ARG_TARGETNAME,
};

/** @Override */
protected function bool CheckTargets(KFTHPCommandExecutionState ExecState)
{
    local PlayerController Target;
    local string TargetName;

    switch (ExecState.GetArgC())
    {
        case 1:
            return true;

        case 2:
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
        case 1:
            return PC == ExecState.GetSender();

        case 2:
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
    MinArgsNum=1
    MaxArgsNum=2
    ArgTypes(0)="number"
    ArgTypes(1)="any"
    CommandStateClass=Class'KFTHPCommandPreservingState'
}
