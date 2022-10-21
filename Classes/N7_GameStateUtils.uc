class N7_GameStateUtils extends Core.Object within N7_CommandManager;

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

    foreach DynamicActors(class'KFMonster', TargetMonster)
    {
        if (TargetMonster.Health > 0 && !TargetMonster.bDeleteMe)
        {
            KillZed(TargetMonster, bDestroyNextTick);
        }
    }
}

public final function KillZed(KFMonster TargetMonster, optional bool bDestroyNextTick)
{
    TargetMonster.Died(TargetMonster.Controller, class'DamageType', TargetMonster.Location);
    
    if (bDestroyNextTick)
    {
        TargetMonster.bDestroyNextTick = True;
    }
}

/****************************
 *  PLAYERS RELATED UTILS
 ****************************/

public final function ResizePlayer(
    PlayerController PC, float ResizeMultiplier)
{
    if (PC.Pawn != None && PC.Pawn.Health > 0)
    {
        PC.Pawn.SetDrawScale(PC.Pawn.default.DrawScale * ResizeMultiplier);
        if (!PC.Pawn.bIsCrouched && !PC.Pawn.bWantsToCrouch)
        {
            PC.Pawn.SetCollisionSize(
                PC.Pawn.default.CollisionRadius * PC.Pawn.DrawScale,
                PC.Pawn.default.CollisionHeight * PC.Pawn.DrawScale
            );
        }
        else
        {
            PC.Pawn.BaseEyeHeight = FMin(
                0.8 * PC.Pawn.default.CrouchHeight, 
                PC.Pawn.default.CrouchHeight - 10
            );
        }
        PC.Pawn.CrouchRadius = PC.Pawn.default.CrouchRadius * PC.Pawn.DrawScale;
        PC.Pawn.CrouchHeight = PC.Pawn.default.CrouchHeight * PC.Pawn.DrawScale;
    }
}

public final function RestorePlayerAttributes(PlayerController PC)
{
    local Inventory Inv;

    if (PC != None && PC.Pawn != None && PC.Pawn.Health > 0)
    {
        PC.Pawn.Health = Max(PC.Pawn.Health, PC.Pawn.default.HealthMax);
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
    KFGT.bZEDTimeActive = False;
    KFGT.LastZedTimeEvent = Level.TimeSeconds;
    KFGT.CurrentZEDTimeDuration = 0.0;
    KFGT.SetGameSpeed(1.0);
    KFGT.ZedTimeExtensionsUsed = 0;
}

public final function DoWaveEnd()
{
    local Controller C;
    local KFDoorMover KFDM;

    KFGT.bDidTraderMovingMessage = False;
    KFGT.bDidMoveTowardTraderMessage = False;

    KFGT.bWaveInProgress = False;
    KFGT.bWaveBossInProgress = False;
    KFGT.bNotifiedLastManStanding = False;
    KFGameReplicationInfo(KFGT.GameReplicationInfo).bWaveInProgress = False;

    KFGT.WaveCountDown = Max(KFGT.TimeBetweenWaves, 1);
    KFGameReplicationInfo(KFGT.GameReplicationInfo).TimeToNextWave = KFGT.WaveCountDown;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if (KFPlayerController(C) != None && KFPlayerReplicationInfo(C.PlayerReplicationInfo) != None)
        {
            C.PlayerReplicationInfo.bOutOfLives = False;
            C.PlayerReplicationInfo.NumLives = 1;

            KFPlayerController(C).bChangedVeterancyThisWave = False;

            if (KFPlayerReplicationInfo(C.PlayerReplicationInfo).ClientVeteranSkill != KFPlayerController(C).SelectedVeterancy)
            {
                KFPlayerController(C).SendSelectedVeterancyToServer();
            }

            if (C.Pawn == None && !C.PlayerReplicationInfo.bOnlySpectator)
            {
                C.PlayerReplicationInfo.Score = Max(KFGT.MinRespawnCash, int(C.PlayerReplicationInfo.Score));

                PlayerController(C).GotoState('PlayerWaiting');
                PlayerController(C).SetViewTarget(C);
                PlayerController(C).ClientSetBehindView(False);
                PlayerController(C).bBehindView = False;
                PlayerController(C).ClientSetViewTarget(C.Pawn);

                C.ServerReStartPlayer();
            }

            KFPlayerController(C).bSpawnedThisWave = False;
        }
    }

    KFGT.bUpdateViewTargs = True;

    foreach DynamicActors(class'KFDoorMover', KFDM)
    {
        KFDM.RespawnDoor();
    }
}

defaultproperties
{}
