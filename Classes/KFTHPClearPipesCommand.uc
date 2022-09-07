class KFTHPClearPipesCommand extends KFTHPGameSettingsCommand;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local PipeBombProjectile PipeBomb;

    foreach DynamicActors(class'PipeBombProjectile', PipeBomb)
    {
        PipeBomb.bHidden = true;
        PipeBomb.Destroyed();
    }
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
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
