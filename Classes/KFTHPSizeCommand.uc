/**
 * This class provides common logic for commands
 * that change players' draw scale (body, head etc.)
 */
class KFTHPSizeCommand extends KFTHPBinaryNumericTargetCommand
    abstract;

var protected const float MinScale; 
var protected const float MaxScale;

/** @Override */
protected function bool CheckGameState(KFTHPCommandExecutionState ExecState)
{
    if (KFGT.IsInState('MatchInProgress'))
    {
        return true;
    }

    return false;
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local float NewScale;
    NewScale = ToFloat(ExecState.GetArg(ECmdArgs.ARG_NUMBER));

    if (!IsInRangeF(NewScale, MinScale, MaxScale))
    {
        return false; 
    }

    KFTHPCommandPreservingState(ExecState).SaveNumberF(NewScale);

    return true;
}

/** @Override */
protected function bool CheckTargets(KFTHPCommandExecutionState ExecState)
{
    local PlayerController Target;
    local string TargetName;

    switch (ExecState.GetArgC())
    {
        case 0:
            return ExecState.GetSender().Pawn != None;

        case 1:
            TargetName = ExecState.GetArg(ECmdArgs.ARG_TARGETNAME);
            KFTHPCommandPreservingState(ExecState).SaveString(TargetName);

            if (TargetName ~= "all")
            {
                return true;
            }

            Target = FindTarget(TargetName);
            if (Target != None && Target.Pawn != None)
            {
                KFTHPCommandPreservingState(ExecState).SaveString(Target.PlayerReplicationInfo.PlayerName);
                return true;
            }
    }
    return false;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Draw scale can be set only during the game";
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "New draw scale must be in range from "$MinScale$" to "$MaxScale;
}

/** @Override */
protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return "Only alive players can be set draw scale";
}

defaultproperties
{
    MinScale=0.1
    MaxScale=10.0
}
