class KFTHPRespawnDoorsCommand extends KFTHPGameSettingsCommand;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local KFUseTrigger KFUT;
    local int i;

    foreach DynamicActors(Class'KFUseTrigger', KFUT)
    {
        for (i = 0; i < KFUT.DoorOwners.Length; i++)
        {
            KFUT.DoorOwners[i].RespawnDoor();
        }
    }
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "All doors have been respawned by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    Aliases(0)="RD"
    Aliases(1)="RESPAWNDOORS"
    Description="Respawn all doors"
}
