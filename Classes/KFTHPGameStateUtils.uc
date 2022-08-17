class KFTHPGameStateUtils extends Core.Object within KFTHPCommandManager;

public final function int GetAlivePlayersNum()
{
    local Controller C;
    local int AlivePlayersNum;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if ((C.IsA('PlayerController') || C.IsA('xBot')) && C.Pawn != None && C.Pawn.Health > 0)
        { 
            AlivePlayersNum++;
        }
    }
    return AlivePlayersNum;
}

public final function int GetRealPlayersNum()
{
    local Controller C;
    local int RealPlayersNum;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if ((C.IsA('PlayerController') || C.IsA('xBot')) && MessagingSpectator(C) == None)
        {
            RealPlayersNum++;
        }
    }
    return RealPlayersNum;
}

public final function int GetFinalZedHPConfig()
{
    local int AlivePlayersNum;

    AlivePlayersNum = GetAlivePlayersNum();

    if (AlivePlayersNum >= GetZedHPConfigThreshold())
    {
        return GetZedHPConfig();
    }

    return Max(AlivePlayersNum, GetZedHPConfig());
}

public final function int GetZedModifiedHealth(KFMonster Zed)
{
    local float ZedRawHealth, ZedHealthModifiedByDifficulty, ZedModifiedHealth;

    ZedRawHealth = Zed.default.Health;
    ZedHealthModifiedByDifficulty = ZedRawHealth * Zed.DifficultyHealthModifer();
    ZedModifiedHealth = ZedHealthModifiedByDifficulty * GetZedHPModifierByPlayers(Zed);

    return ZedModifiedHealth;
}

public final function int GetZedModifiedHeadHealth(KFMonster Zed)
{
    local float ZedRawHeadHealth, ZedHeadHealthModifiedByDifficulty, ZedModifiedHeadHealth;

    ZedRawHeadHealth = Zed.default.HeadHealth;
    ZedHeadHealthModifiedByDifficulty = ZedRawHeadHealth * Zed.DifficultyHeadHealthModifer();
    ZedModifiedHeadHealth = ZedHeadHealthModifiedByDifficulty * GetZedHeadHPModifierByPlayers(Zed);

    return ZedModifiedHeadHealth;
}

protected final function float GetZedHPModifierByPlayers(KFMonster Zed)
{
    return 1.0 + Zed.PlayerCountHealthScale * FMax(GetFinalZedHPConfig() - 1.0, 0);
}

protected final function float GetZedHeadHPModifierByPlayers(KFMonster Zed)
{
    return 1.0 + Zed.PlayerNumHeadHealthScale * FMax(GetFinalZedHPConfig() - 1.0, 0);
}

defaultproperties
{}
