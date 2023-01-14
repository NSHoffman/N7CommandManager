class N7_HPConfigModel extends Core.Object within N7_CommandManager;

var protected const int ZedHPConfigThreshold;
var protected int ZedHPConfig;

public final function int GetZedHPConfig()
{
    local int AlivePlayersNum;

    AlivePlayersNum = GetAlivePlayersNum();

    if (AlivePlayersNum >= GetZedHPConfigThreshold())
    {
        return ZedHPConfig;
    }

    return Max(AlivePlayersNum, ZedHPConfig);
}

public final function SetZedHPConfig(int NewZedHPConfig)
{
    ZedHPConfig = NewZedHPConfig;
}

public final function int GetZedHPConfigThreshold()
{
    return ZedHPConfigThreshold;
}

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
    return 1.0 + Zed.PlayerCountHealthScale * FMax(GetZedHPConfig() - 1.0, 0);
}

protected final function float GetZedHeadHPModifierByPlayers(KFMonster Zed)
{
    return 1.0 + Zed.PlayerNumHeadHealthScale * FMax(GetZedHPConfig() - 1.0, 0);
}

defaultproperties
{
    ZedHPConfig=1
    ZedHPConfigThreshold=6
}
