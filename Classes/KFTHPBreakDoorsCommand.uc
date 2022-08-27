class KFTHPBreakDoorsCommand extends KFTHPGameSettingsCommand;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local KFUseTrigger KFUT;
    local KFDoorMover KFDM;
    local int i;

    foreach DynamicActors(Class'KFUseTrigger', KFUT)
    {
        for (i = 0; i < KFUT.DoorOwners.Length; i++)
        {
            KFDM = KFUT.DoorOwners[i];
            KFDM.TakeDamage(KFDM.Health, ExecState.GetSender().Pawn, KFDM.Location, vect(0, 0, 0), Class'DamTypeFrag');
        }
    }
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "All welded doors have been destroyed by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    Aliases(0)="BD"
    Aliases(1)="BREAKDOORS"
    Signature="<>"
    Description="Break all welded doors"
}
