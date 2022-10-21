class N7_ClearPipesCommand extends N7_GameSettingsCommand;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local PipeBombProjectile PipeBomb;

    foreach DynamicActors(class'PipeBombProjectile', PipeBomb)
    {
        PipeBomb.bHidden = True;
        PipeBomb.Destroyed();
    }
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return !KFGT.IsInState('PendingMatch') 
        && (KFGT.WaveCountDown > 0 || IsAdmin(ExecState.GetSender()));
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Pipes can be removed only during trade time";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "All pipes have been removed by "$ColorizeSender(ExecState);
}

defaultproperties
{
    Aliases(0)="CP"
    Aliases(1)="CLEARPIPES"
    Signature="<>"
    Description="Remove all pipes from level"
}
