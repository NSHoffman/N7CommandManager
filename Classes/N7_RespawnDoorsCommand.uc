class N7_RespawnDoorsCommand extends N7_GameSettingsCommand;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local KFDoorMover KFDM;

    foreach DynamicActors(class'KFMod.KFDoorMover', KFDM)
    {
        if (KFDM != None)
        {
            KFDM.RespawnDoor();
        }
    }
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "All doors have been respawned by "$ColorizeSender(ExecState);
}

defaultproperties
{
    Aliases(0)="RD"
    Aliases(1)="RESPAWNDOORS"
    Description="Respawn all doors"
    Signature="<>"

    bOnlyAliveSender=True
}
