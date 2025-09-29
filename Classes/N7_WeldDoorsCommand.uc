class N7_WeldDoorsCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_FLAG,
};

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
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
            bTriggerDoorsClosed = True;

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
                KFUT.AddWeld(KFUT.MaxWeldStrength, False, None);
            }
        }

        ExecState.SaveString("welded");
    }
    else if (IsSwitchOffValue(Flag))
    {
        foreach DynamicActors(class'KFDoorMover', KFDM)
        {
            if (!KFDM.bDoorIsDead) 
            {
                KFDM.MyTrigger.UnWeld(KFDM.WeldStrength, False, None);
            }
        }

        ExecState.SaveString("unwelded");
    }
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string DoorsState;
    DoorsState = ColorizeValue(ExecState.LoadString());

    return "All doors are "$DoorsState$" by "$ColorizeSender(ExecState);
}

defaultproperties
{
    MinArgsNum=1
    MaxArgsNum=1
    ArgTypes(0)="switch"

    Aliases(0)="WELD"
    Description="Weld all doors"
    Signature="<(0 | 1 | ON | OFF)>"
    
    bOnlyAliveSender=True
}
