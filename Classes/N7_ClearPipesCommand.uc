class N7_ClearPipesCommand extends N7_GameSettingsCommand;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local PipeBombProjectile PipeBomb;

    foreach DynamicActors(class'PipeBombProjectile', PipeBomb)
    {
        PipeBomb.bHidden = true;
        PipeBomb.Destroyed();
    }
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "All pipes have been removed by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    Aliases(0)="CP"
    Aliases(1)="CLEARPIPES"
    Signature="<>"
    Description="Remove all pipes from level"
}
