class N7_BreakDoorsCommand extends N7_GameSettingsCommand;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local KFDoorMover KFDM;
    local Pawn InstigatedBy;
    local Vector HitLocation, Momentum;
    local class<DamageType> DamageType;

    foreach DynamicActors(class'KFMod.KFDoorMover', KFDM)
    {
        if (KFDM != None)
        {
            KFDM.GoBang(InstigatedBy, HitLocation, Momentum, DamageType);
        }
    }
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "All doors have been destroyed by "$ColorizeSender(ExecState);
}

defaultproperties
{
    Aliases(0)="BD"
    Aliases(1)="BREAKDOORS"
    Description="Break all doors"
    Signature="<>"

    bOnlyAliveSender=True
}
