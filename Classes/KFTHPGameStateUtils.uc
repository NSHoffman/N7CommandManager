class KFTHPGameStateUtils extends Core.Object within KFTHPCommandManager;

/****************************
 *  SETTINGS ACCESSORS
 ****************************/

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

/****************************
 *  ZEDS RELATED UTILS
 ****************************/

public final function KillAllZeds(optional bool bDestroyNextTick)
{
    KillLivingZeds(bDestroyNextTick);

    KFGT.NumMonsters = 0;
    KFGT.TotalMaxMonsters = 0;
    KFGT.MaxMonsters = 0;
    KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonsters = 0;
}

public final function KillLivingZeds(optional bool bDestroyNextTick)
{
    local KFMonster TargetMonster;

    foreach DynamicActors(Class'KFMonster', TargetMonster)
    {
        if (TargetMonster.Health > 0 && !TargetMonster.bDeleteMe)
        {
            KillZed(TargetMonster, bDestroyNextTick);
        }
    }
}

public final function KillZed(KFMonster TargetMonster, optional bool bDestroyNextTick)
{
    TargetMonster.Died(TargetMonster.Controller, Class'DamageType', TargetMonster.Location);
    
    if (bDestroyNextTick)
    {
        TargetMonster.bDestroyNextTick = true;
    }
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

/****************************
 *  PLAYERS RELATED UTILS
 ****************************/

public final function ResizePlayer(
    PlayerController PC, float ResizeMultiplier)
{
    if (PC.Pawn != None && PC.Pawn.Health > 0)
    {
        PC.Pawn.SetDrawScale(PC.Pawn.Default.DrawScale * ResizeMultiplier);

        if (!PC.Pawn.bIsCrouched)
        {
            PC.Pawn.SetCollisionSize(
                PC.Pawn.Default.CollisionRadius * ResizeMultiplier, 
                PC.Pawn.Default.CollisionHeight * ResizeMultiplier
            );
        }
        else
        {
            PC.Pawn.CrouchRadius = PC.Pawn.Default.CrouchRadius * ResizeMultiplier; 
            PC.Pawn.CrouchHeight = PC.Pawn.Default.CrouchHeight * ResizeMultiplier;
            PC.Pawn.BaseEyeHeight = FMin(0.8 * PC.Pawn.Default.CrouchHeight, PC.Pawn.Default.CrouchHeight - 10);
        }
    }
}

public final function RestorePlayerAttributes(PlayerController PC)
{
    local Inventory Inv;

    if (PC != None && PC.Pawn != None && PC.Pawn.Health > 0)
    {
        PC.Pawn.Health = PC.Pawn.Default.HealthMax;
        PC.Pawn.AddShieldStrength(100);
        
        for (Inv = PC.Pawn.Inventory; Inv != None; Inv = Inv.Inventory)
        {
            if (Weapon(Inv) != None)
            {
                KFWeapon(Inv).MagAmmoRemaining = KFWeapon(Inv).MagCapacity;
                Weapon(Inv).MaxOutAmmo();
            }
        }
    }
}

/****************************
 *  GAME RELATED UTILS
 ****************************/

public final function StopZedTime()
{
    KFGT.bZEDTimeActive = false;
    KFGT.LastZedTimeEvent = Level.TimeSeconds;
    KFGT.CurrentZEDTimeDuration = 0.0;
    KFGT.SetGameSpeed(1.0);
    KFGT.ZedTimeExtensionsUsed = 0;
}

public final function DoWaveEnd()
{
    local Controller C;
    local KFDoorMover KFDM;

    KFGT.bDidTraderMovingMessage = false;
    KFGT.bDidMoveTowardTraderMessage = false;

    KFGT.bWaveInProgress = false;
    KFGT.bWaveBossInProgress = false;
    KFGT.bNotifiedLastManStanding = false;
    KFGameReplicationInfo(KFGT.GameReplicationInfo).bWaveInProgress = false;

    KFGT.WaveCountDown = Max(KFGT.TimeBetweenWaves, 1);
    KFGameReplicationInfo(KFGT.GameReplicationInfo).TimeToNextWave = KFGT.WaveCountDown;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (KFPlayerController(C) != None && KFPlayerReplicationInfo(C.PlayerReplicationInfo) != None)
        {
            C.PlayerReplicationInfo.bOutOfLives = false;
            C.PlayerReplicationInfo.NumLives = 1;

            KFPlayerController(C).bChangedVeterancyThisWave = false;

            if (KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkill != KFPlayerController(C).SelectedVeterancy)
            {
                KFPlayerController(C).SendSelectedVeterancyToServer();
            }

            if (C.Pawn == None && !C.PlayerReplicationInfo.bOnlySpectator)
            {
                C.PlayerReplicationInfo.Score = Max(KFGT.MinRespawnCash, int(C.PlayerReplicationInfo.Score));

                PlayerController(C).GotoState('PlayerWaiting');
                PlayerController(C).SetViewTarget(C);
                PlayerController(C).ClientSetBehindView(false);
                PlayerController(C).bBehindView = false;
                PlayerController(C).ClientSetViewTarget(C.Pawn);

                C.ServerReStartPlayer();
            }

            KFPlayerController(C).bSpawnedThisWave = false;
        }
    }

    KFGT.bUpdateViewTargs = true;

    foreach DynamicActors(Class'KFDoorMover', KFDM)
    {
        KFDM.RespawnDoor();
    }
}

defaultproperties
{}
