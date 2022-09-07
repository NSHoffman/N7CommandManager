/**
 * This class provides common logic for commands
 * that change players' draw scale (body, head etc.)
 */
class KFTHPSizeCommand extends KFTHPBinaryTargetCommand
    abstract;

var protected const float MinScale; 
var protected const float MaxScale;

/** @Override */
protected function bool CheckGameState(KFTHPCommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local float NewScale;
    NewScale = ToFloat(ExecState.GetArg(ECmdArgs.ARG_VALUE));

    if (ExecState.GetArgC() == 0)
    {
        NewScale = 1.0;
    }

    if (!IsInRangeF(NewScale, MinScale, MaxScale))
    {
        return false; 
    }

    KFTHPCommandPreservedState(ExecState).SaveNumberF(NewScale);

    return true;
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
    MaxScale=5.0
    bOnlyAliveTargets=true
}
