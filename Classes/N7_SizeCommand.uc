/**
 * This class provides common logic for commands
 * that change players' draw scale (body, head etc.)
 */
class N7_SizeCommand extends N7_BinaryTargetCommand
    abstract;

var protected config const float MinLimit; 
var protected config const float MaxLimit;

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return !KFGT.IsInState('PendingMatch');
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local float NewScale;
    NewScale = float(ExecState.GetArg(ECmdArgs.ARG_VALUE));

    if (ExecState.GetArgC() == 0)
    {
        NewScale = 1.0;
    }

    if (!IsInRangeF(NewScale, MinLimit, MaxLimit))
    {
        return False; 
    }

    ExecState.SaveNumberF(NewScale);

    return True;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Draw scale can be set only during the game";
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "New draw scale must be in range from "$MinLimit$" to "$MaxLimit;
}

/** @Override */
protected function string InvalidTargetMessage(N7_CommandExecutionState ExecState)
{
    return "Only alive players can be set draw scale";
}

defaultproperties
{
    MinLimit=0.1
    MaxLimit=5.0
    bOnlyAliveTargets=True
    bNotifySenderOnSuccess=True
}
