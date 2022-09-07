class KFTHPWeldDoorsCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_FLAG,
};

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local KFUseTrigger KFUT;
    local KFDoorMover KFDM;
    local string Flag;
    local bool bTriggerDoorsClosed;
    local int i;

    Flag = ExecState.GetArg(ECmdArgs.ARG_FLAG);

    if (IsSwitchOnValue(Flag))
    {
        foreach DynamicActors(class'KFUseTrigger', KFUT)
        {
            bTriggerDoorsClosed = true;

            for (i = 0; i < KFUT.DoorOwners.Length; i++)
            {
                KFDM = KFUT.DoorOwners[i];
                if (!KFDM.bDoorIsDead)
                {
                    if (!KFDM.bClosed)
                    {
                        KFDM.DoClose();
                        KFDM.FinishedClosing();
                        KFDM.EnableTrigger();
                    }
                    bTriggerDoorsClosed = bTriggerDoorsClosed && KFDM.bClosed;
                }
            }

            if (bTriggerDoorsClosed)
            {
                KFUT.AddWeld(KFUT.MaxWeldStrength, false, None);
            }
        }

        KFTHPCommandPreservedState(ExecState).SaveString("welded");
    }
    else if (IsSwitchOffValue(Flag))
    {
        foreach DynamicActors(class'KFDoorMover', KFDM)
        {
            if (!KFDM.bDoorIsDead) 
            {
                KFDM.MyTrigger.UnWeld(KFDM.WeldStrength, false, None);
            }
        }

        KFTHPCommandPreservedState(ExecState).SaveString("unwelded");
    }
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "All doors are "$KFTHPCommandPreservedState(ExecState).LoadString()$" by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    MinArgsNum=1
    MaxArgsNum=1
    Aliases(0)="WELD"
    ArgTypes(0)="switch"
    Signature="<(0 | 1 | ON | OFF)>"
    Description="Weld all doors"
}
