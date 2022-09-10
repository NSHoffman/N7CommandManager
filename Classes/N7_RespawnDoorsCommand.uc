class N7_RespawnDoorsCommand extends N7_GameSettingsCommand;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local KFUseTrigger KFUT;
    local int i;

    foreach DynamicActors(class'KFUseTrigger', KFUT)
    {
        for (i = 0; i < KFUT.DoorOwners.Length; i++)
        {
            KFUT.DoorOwners[i].RespawnDoor();
        }
    }
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "All doors have been respawned by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    Aliases(0)="RD"
    Aliases(1)="RESPAWNDOORS"
    Signature="<>"
    Description="Respawn all doors"
}
