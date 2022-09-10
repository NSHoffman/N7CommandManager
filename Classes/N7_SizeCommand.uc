/**
 * This class provides common logic for commands
 * that change players' draw scale (body, head etc.)
 */
class N7_SizeCommand extends N7_BinaryTargetCommand
    abstract;

var protected config const float MinScale; 
var protected config const float MaxScale;

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
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

    N7_CommandPreservedState(ExecState).SaveNumberF(NewScale);

    return true;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Draw scale can be set only during the game";
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "New draw scale must be in range from "$MinScale$" to "$MaxScale;
}

/** @Override */
protected function string InvalidTargetMessage(N7_CommandExecutionState ExecState)
{
    return "Only alive players can be set draw scale";
}

defaultproperties
{
    MinScale=0.1
    MaxScale=5.0
    bOnlyAliveTargets=true
}
