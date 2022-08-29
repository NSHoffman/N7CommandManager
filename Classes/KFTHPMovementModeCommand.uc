/**
 * This class provides common logic for commands
 * that switch players between various movement settings presets
 * like normal walking, flying, ghosting etc.
 */
class KFTHPMovementModeCommand extends KFTHPUnaryTargetCommand
    abstract;

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
