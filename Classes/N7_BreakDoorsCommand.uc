class N7_BreakDoorsCommand extends N7_GameSettingsCommand;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local KFUseTrigger KFUT;
    local KFDoorMover KFDM;
    local int i;

    foreach DynamicActors(class'KFUseTrigger', KFUT)
    {
        for (i = 0; i < KFUT.DoorOwners.Length; i++)
        {
            KFDM = KFUT.DoorOwners[i];
            KFDM.TakeDamage(KFDM.Health, ExecState.GetSender().Pawn, KFDM.Location, vect(0, 0, 0), class'DamTypeFrag');
        }
    }
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
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
