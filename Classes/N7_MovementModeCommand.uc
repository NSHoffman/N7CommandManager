/**
 * This class provides common logic for commands
 * that switch players between various movement settings presets
 * like normal walking, flying, ghosting etc.
 */
class N7_MovementModeCommand extends N7_UnaryTargetCommand
    abstract;

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Movement settings can be modified only during the game";
}

defaultproperties
{
    bAdminOnly=true
    bOnlyAliveTargets=true
    bNotifyGlobalOnSuccess=true
}
