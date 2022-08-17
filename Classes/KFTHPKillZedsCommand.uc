class KFTHPKillZedsCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_TARGET,
};

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local KFGameReplicationInfo KFGRI;
    KFGRI = KFGameReplicationInfo(Level.Game.GameReplicationInfo);

    KillLivingZeds();

    if (ExecState.GetArgC() == 1)
    {
        KFGT.NumMonsters = 0;
        KFGT.TotalMaxMonsters = 0;
        KFGT.MaxMonsters = 0;
        KFGRI.MaxMonsters = 0;
    }
}

protected function KillLivingZeds()
{
    local KFMonster TargetMonster;

    foreach DynamicActors(Class'KFMonster', TargetMonster)
    {
        if (TargetMonster.Health > 0 && !TargetMonster.bDeleteMe)
        {
            KillZed(TargetMonster);
        }
    }
}

protected function KillZed(KFMonster TargetMonster)
{
    TargetMonster.Died(TargetMonster.Controller, Class'DamageType', TargetMonster.Location);
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local string TargetString;

    if (ExecState.GetArgC() == 1)
    {
        TargetString = Locs(ExecState.GetArg(ECmdArgs.ARG_TARGET));

        if (TargetString != "all")
        {
            return false;
        }
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    if (ExecState.GetArgC() == 1)
    {
        return "Wave cleared by "$GetInstigatorName(ExecState);
    }

    return "ZED Squads killed by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "Command only accepts 'all' as an argument";
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="KZ"
    Aliases(1)="KILLZEDS"
    ArgTypes(0)="word"
    Signature="<optional string 'all'>"
    Description="Kill ZEDs"
}
