class N7_CommandManager extends Engine.Mutator
    dependson(N7_ResizedPlayersModel)
    config(N7CommandManager);

var public KFGameType KFGT;

/** Class responsible for messages/notifications coloring */
var protected const class<N7_CommandMessageColors> ColorsClass;
var public N7_CommandMessageColors Colors;

/** Class which provides API for input validation */
var protected const class<N7_CommandValidator> ValidatorClass;
var public N7_CommandValidator Validator;

/** Class which contains some helper functions to work with game state */
var protected const class<N7_GameStateUtils> GSUClass;
var public N7_GameStateUtils GSU;

/** Models */
var protected const class<N7_RestoredPlayersModel> RestoredPlayersModelClass;
var public N7_RestoredPlayersModel RestoredPlayersModel;

var protected const class<N7_InfiniteAmmoPlayersModel> InfiniteAmmoPlayersModelClass;
var public N7_InfiniteAmmoPlayersModel InfiniteAmmoPlayersModel;

var protected const class<N7_ResizedPlayersModel> ResizedPlayersModelClass;
var public N7_ResizedPlayersModel ResizedPlayersModel;

var protected const class<N7_HPConfigModel> HPConfigModelClass;
var public N7_HPConfigModel HPConfigModel;

var protected const class<N7_FakedPlayersModel> FakedPlayersModelClass;
var public N7_FakedPlayersModel FakedPlayersModel;

/** Properties */
var protected Array<KFPlayerController> PendingPlayers;
var protected bool bHasPendingPlayers;

/** Commands List */
var protected config Array<string> CommandClassNames;
var protected Array<N7_Command> Commands;

/** Game settings */
var public float OriginalWaveSpawnPeriod;
var public bool bOriginalWaveSpawnPeriodSaved;

var protected bool bZedTimeEnabled;
var protected int LastWaveCountDown;
var protected float LastAttributeRestoreTime;

var protected config int ZedHPConfigThreshold;

/*********************************
 * INITIALIZATION
 *********************************/

protected function InitServices()
{
    Colors      = new(self) ColorsClass;
    Validator   = new(self) ValidatorClass;
    GSU         = new(self) GSUClass;
}

protected function InitModels()
{
    RestoredPlayersModel     = new(self) RestoredPlayersModelClass;
    InfiniteAmmoPlayersModel = new(self) InfiniteAmmoPlayersModelClass;
    ResizedPlayersModel      = new(self) ResizedPlayersModelClass;
    HPConfigModel            = new(self) HPConfigModelClass;
    FakedPlayersModel        = new(self) FakedPlayersModelClass;
}

protected function InitCommands()
{
    local int i;
    local class<N7_Command> CommandClass;

    Commands.Length = 0;

    for (i = 0; i < CommandClassNames.Length; i++)
    {
        if (CommandClassNames[i] == "")
        {
            continue;
        }

        CommandClass = class<N7_Command>(DynamicLoadObject(CommandClassNames[i], class'Class', True));

        if (CommandClass == None)
        {
            Warn("Could not load class" @ CommandClass);
            continue;
        }

        Commands[Commands.Length] = new(self) CommandClass;
    }
}

protected function SaveConfiguration()
{
    local int i;

    self.SaveConfig();

    Colors.SaveConfig();
    Colors.ColorManager.static.StaticSaveConfig();

    for (i = 0; i < Commands.Length; i++)
    {
        if (Commands[i] != None) 
        {
            Commands[i].SaveConfig();
        }
    }
}

/*********************************
 * EVENTS
 *********************************/

event PostBeginPlay()
{
    KFGT = KFGameType(Level.Game);

    if (KFGT == None)
    {
        Destroy();
    }

    LastWaveCountDown = KFGT.WaveCountDown;

    InitServices();
    InitModels();
    InitCommands();
    SaveConfiguration();

    SetTimer(1.0, True);
}

public function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local KFMonster Zed;
    local int ZedHealthDesired, ZedHeadHealthDesired;

    /** 
     * Changing Monsters HP modifiers depending on
     * current HP config and number of players alive
     *
     * The code in CheckReplacement() gets executed before
     * KFMonster::PostBeginPlay() and thus to get the correct health value
     * we need to divide the desired ZED hp by the modifier that is going
     * to be applied in KFMonster::PostBeginPlay() so that it can be multiplied back
     */
    if (KFMonster(Other) != None)
    {
        Zed = KFMonster(Other);

        ZedHealthDesired = GetZedModifiedHealth(Zed);
        ZedHeadHealthDesired = GetZedModifiedHeadHealth(Zed);

        Zed.HealthMax = ZedHealthDesired 
            / Zed.NumPlayersHealthModifer() 
            / Zed.DifficultyHealthModifer();
        
        Zed.Health = Zed.HealthMax;

        Zed.HeadHealth = ZedHeadHealthDesired 
            / Zed.NumPlayersHeadHealthModifer() 
            / Zed.DifficultyHeadHealthModifer();
    }

    if (KFPlayerController(Other) != None)
	{
		PendingPlayers[PendingPlayers.Length] = KFPlayerController(Other);
		bHasPendingPlayers = True;
	}

    return True;
}

public function Mutate(string MutateString, PlayerController Sender)
{
    local int MutateCommandIndex;
    local Array<string> MutateArgs;

    Split(MutateString, " ", MutateArgs);

    if (MutateArgs.Length > 0)
    {
        MutateCommandIndex = GetCommandIndex(MutateArgs[0]);
        
        if (MutateCommandIndex != -1)
        {
            Commands[MutateCommandIndex].Execute(Sender, MutateArgs);
        }
    }

    super.Mutate(MutateString, Sender);
}

event Timer()
{
    local Controller C;
    local PlayerController PC;

    /** 
     * When new players join the game, they might be added to attribute restoration list
     * That happens in case if all other players already have attribute restoration enabled
     */
	if (bHasPendingPlayers)
	{
		while (PendingPlayers.Length > 0)
		{
			PC = PendingPlayers[0];

			if (PC != None)
			{
				if (GetRealPlayersNum() > 0 && GetRestoredPlayers().Length > 0 && FindRestoredPlayer(PC) == "" && GetRestoredPlayers().Length == GetRealPlayersNum() - 1)
				{
					AddRestoredPlayer(PC);
				}
			}

			PendingPlayers.Remove(0, 1);
		}

		bHasPendingPlayers = False;
	}

    /**
     * Actual default spawn rate value must be taken when KFGT.KFLRules is initialized
     */
    if (KFGT != None && KFGT.KFLRules != None && !bOriginalWaveSpawnPeriodSaved)
    {
        OriginalWaveSpawnPeriod = KFGT.KFLRules.WaveSpawnPeriod;
        bOriginalWaveSpawnPeriodSaved = true;
    }

    /** 
     * Constantly delaying next ZED-Time event
     * so that it will never occur if bZedTimeEnabled is False
     */
    if (!IsZedTimeEnabled())
    {
        KFGT.LastZedTimeEvent = Level.TimeSeconds;
    }

    /**
	 * Keeping players' ammo refilled
	 */
	if (GetInfiniteAmmoPlayers().Length > 0)
	{
		for (C = Level.ControllerList; C != None; C = C.NextController)
		{
			PC = PlayerController(C);

			if (PC != None && PC.Pawn != None && PC.Pawn.Health > 0)
			{
				if (FindInfiniteAmmoPlayer(PC) != "")
				{
					GSU.RestorePlayerAmmo(PC);
				}
			}
		}
	}
}

event Tick(float DeltaTime)
{
    local Controller C;
    local PlayerController PC;
    local bool bWaveEnd, bWaveStart; 
    local Array<N7_ResizedPlayersModel.ResizedPlayer> ResizedPlayers;
    local N7_ResizedPlayersModel.ResizedPlayer RP;
    local Array<string> RestoredPlayers;

    /**
    * Keeping players' bodies resized
    */
    ResizedPlayers = GetResizedPlayers();
    if (ResizedPlayers.Length > 0)
    {
        RefreshResizedPlayers();

        for (C = Level.ControllerList; C != None; C = C.NextController)
        {
            PC = PlayerController(C);

            if (PC != None && PC.Pawn != None && PC.Pawn.Health > 0)
            {
                RP = FindResizedPlayer(PC);
                if (RP.Hash != "")
                {
                    GSU.ResizePlayer(PC, RP.ResizeMultiplier);
                }
            }
        }
    }

    bWaveStart = KFGT.WaveCountDown <= 1 && !KFGT.bWaveInProgress && !KFGT.bWaveBossInProgress;
    bWaveEnd = LastWaveCountDown == 0 && KFGT.WaveCountDown > 0;
    LastWaveCountDown = KFGT.WaveCountDown;

    /**
    * Keeping players' attributes restored
    */
    RestoredPlayers = GetRestoredPlayers();
    if (RestoredPlayers.Length > 0 && Level.TimeSeconds - LastAttributeRestoreTime > 2.0)
    {
        if (bWaveStart || bWaveEnd)
        {
            for (C = Level.ControllerList; C != None; C = C.NextController)
            {
                PC = PlayerController(C);

                if (PC != None && PC.Pawn != None && PC.Pawn.Health > 0)
                {
                    if (FindRestoredPlayer(PC) != "")
                    {
                        GSU.RestorePlayerAttributes(PC);
                        PC.ClientMessage("Your attributes have been restored");
                    }
                }
            }

            LastAttributeRestoreTime = Level.TimeSeconds;
        }
    }
}

/*********************************
 * DATA ACCESSORS
 *********************************/

public final function bool IsZedTimeEnabled()
{
    return bZedTimeEnabled;
}

public final function SetZedTime(bool Flag)
{
    bZedTimeEnabled = Flag;
}

/*********************************
 * MODELS API
 *********************************/

public final function Array<string> GetRestoredPlayers()
{
    return RestoredPlayersModel.GetRestoredPlayers();
}

public final function RefreshRestoredPlayers()
{
    RestoredPlayersModel.RefreshRestoredPlayers();
}

public final function AddRestoredPlayer(PlayerController PC)
{
    RestoredPlayersModel.AddRestoredPlayer(PC);
}

public final function RemoveRestoredPlayer(PlayerController PC)
{
    RestoredPlayersModel.RemoveRestoredPlayer(PC);
}

public final function string FindRestoredPlayer(PlayerController PC)
{
    return RestoredPlayersModel.FindRestoredPlayer(PC);
}

public final function Array<string> GetInfiniteAmmoPlayers()
{
	return InfiniteAmmoPlayersModel.GetInfiniteAmmoPlayers();
}

public final function AddInfiniteAmmoPlayer(PlayerController PC)
{
	InfiniteAmmoPlayersModel.AddInfiniteAmmoPlayer(PC);
}

public final function RemoveInfiniteAmmoPlayer(PlayerController PC)
{
	InfiniteAmmoPlayersModel.RemoveInfiniteAmmoPlayer(PC);
}

public final function string FindInfiniteAmmoPlayer(PlayerController PC)
{
	return InfiniteAmmoPlayersModel.FindInfiniteAmmoPlayer(PC);
}

public final function Array<N7_ResizedPlayersModel.ResizedPlayer> GetResizedPlayers()
{
    return ResizedPlayersModel.GetResizedPlayers();
}

public final function RefreshResizedPlayers()
{
    ResizedPlayersModel.RefreshResizedPlayers();
}

public final function AddResizedPlayer(PlayerController PC, float ResizeMultiplier)
{
    ResizedPlayersModel.AddResizedPlayer(PC, ResizeMultiplier);
}

public final function RemoveResizedPlayer(PlayerController PC)
{
    ResizedPlayersModel.RemoveResizedPlayer(PC);
}

public final function N7_ResizedPlayersModel.ResizedPlayer FindResizedPlayer(PlayerController PC)
{
    return ResizedPlayersModel.FindResizedPlayer(PC);
}

public final function int GetZedHPConfig()
{
    return HPConfigModel.GetZedHPConfig();
}

public final function int GetZedHPConfigThreshold()
{
    return ZedHPConfigThreshold;
}

public final function int GetAlivePlayersNum()
{
    return HPConfigModel.GetAlivePlayersNum();
}

public final function int GetZedModifiedHealth(KFMonster Zed)
{
    return HPConfigModel.GetZedModifiedHealth(Zed);
}

public final function int GetZedModifiedHeadHealth(KFMonster Zed)
{
    return HPConfigModel.GetZedModifiedHeadHealth(Zed);
}

public final function int GetFakedPlayersNum()
{
    return FakedPlayersModel.GetFakedPlayersNum();
}

public final function int GetRealPlayersNum()
{
    return FakedPlayersModel.GetRealPlayersNum();
}

public final function SetFakedPlayersNum(int NewFakedPlayersNum)
{
    FakedPlayersModel.SetFakedPlayersNum(NewFakedPlayersNum);
}

/*********************************
 * LOW-LEVEL LOGIC IMPLEMENTATION
 *********************************/

protected final function int GetCommandIndex(string Alias)
{
    local int i;

    for (i = 0; i < Commands.Length; i++)
    {
        if (Commands[i] != None && Commands[i].HasAlias(Alias))
        {
            return i;
        }
    }

    return -1;
}

defaultproperties 
{
    GroupName="KF-N7CommandManager"
    FriendlyName="N7 Command Manager"
    Description="Mutate API for more sophisticated game settings and event triggering."

    ValidatorClass=class'N7CommandManager.N7_CommandValidator'
    ColorsClass=class'N7CommandManager.N7_CommandMessageColors'
    GSUClass=class'N7CommandManager.N7_GameStateUtils'

    RestoredPlayersModelClass=class'N7CommandManager.N7_RestoredPlayersModel'
    ResizedPlayersModelClass=class'N7CommandManager.N7_ResizedPlayersModel'
    InfiniteAmmoPlayersModelClass=class'N7CommandManager.N7_InfiniteAmmoPlayersModel'
    HPConfigModelClass=class'N7CommandManager.N7_HPConfigModel'
    FakedPlayersModelClass=class'N7CommandManager.N7_FakedPlayersModel'

    CommandClassNames(0)="N7CommandManager.N7_HelpCommand"
    CommandClassNames(1)="N7CommandManager.N7_AdminHelpCommand"
    CommandClassNames(2)="N7CommandManager.N7_SlotsCommand"
    CommandClassNames(3)="N7CommandManager.N7_SpectatorsCommand"
    CommandClassNames(4)="N7CommandManager.N7_FakesCommand"
    CommandClassNames(5)="N7CommandManager.N7_ZedHPConfigCommand"
    CommandClassNames(6)="N7CommandManager.N7_SpawnRateCommand"
    CommandClassNames(7)="N7CommandManager.N7_ZedTimeCommand"
    CommandClassNames(8)="N7CommandManager.N7_MaxZedsCommand"
    CommandClassNames(9)="N7CommandManager.N7_StatusCommand"

    CommandClassNames(10)="N7CommandManager.N7_TradeTimeCommand"
    CommandClassNames(11)="N7CommandManager.N7_SkipTradeCommand"
    CommandClassNames(12)="N7CommandManager.N7_WaveIntervalCommand"

    CommandClassNames(13)="N7CommandManager.N7_SetWaveCommand"
    CommandClassNames(14)="N7CommandManager.N7_RestartWaveCommand"
    CommandClassNames(15)="N7CommandManager.N7_RespawnPlayerCommand"
    CommandClassNames(16)="N7CommandManager.N7_RestoreAttributesCommand"

    CommandClassNames(17)="N7CommandManager.N7_ReadyAllCommand"
    CommandClassNames(18)="N7CommandManager.N7_ResetStatsCommand"

    CommandClassNames(19)="N7CommandManager.N7_RespawnDoorsCommand"
    CommandClassNames(20)="N7CommandManager.N7_BreakDoorsCommand"
    CommandClassNames(21)="N7CommandManager.N7_WeldDoorsCommand"

    CommandClassNames(22)="N7CommandManager.N7_ClearPipesCommand"
    CommandClassNames(23)="N7CommandManager.N7_ClearLevelCommand"

    CommandClassNames(24)="N7CommandManager.N7_SetNameCommand"
    CommandClassNames(25)="N7CommandManager.N7_SetPerkCommand"
    CommandClassNames(26)="N7CommandManager.N7_SetPerkLevelCommand"

    CommandClassNames(27)="N7CommandManager.N7_GameSpeedCommand"
    CommandClassNames(28)="N7CommandManager.N7_GravityCommand"

    CommandClassNames(29)="N7CommandManager.N7_SummonCommand"
    CommandClassNames(30)="N7CommandManager.N7_HitZedCommand"
    CommandClassNames(31)="N7CommandManager.N7_KillZedsCommand"

    CommandClassNames(32)="N7CommandManager.N7_SpawnProjCommand"
    CommandClassNames(33)="N7CommandManager.N7_HitPlayerCommand"
    CommandClassNames(34)="N7CommandManager.N7_SlapCommand"

    CommandClassNames(35)="N7CommandManager.N7_GodModeCommand"
    CommandClassNames(36)="N7CommandManager.N7_WalkCommand"
    CommandClassNames(37)="N7CommandManager.N7_SpiderCommand"
    CommandClassNames(38)="N7CommandManager.N7_FlyCommand"
    CommandClassNames(39)="N7CommandManager.N7_GhostCommand"

    CommandClassNames(40)="N7CommandManager.N7_SetPlayerHealthCommand"    
    CommandClassNames(41)="N7CommandManager.N7_SetPlayerArmorCommand"   
    CommandClassNames(42)="N7CommandManager.N7_RestorePlayerAmmoCommand"   
    CommandClassNames(43)="N7CommandManager.N7_InfiniteAmmoCommand"

    CommandClassNames(44)="N7CommandManager.N7_GiveWeaponCommand"
    CommandClassNames(45)="N7CommandManager.N7_GiveCashCommand"

    CommandClassNames(46)="N7CommandManager.N7_TeleportCommand"
    CommandClassNames(47)="N7CommandManager.N7_TeleportToCommand"

    CommandClassNames(48)="N7CommandManager.N7_HeadSizeCommand"
    CommandClassNames(49)="N7CommandManager.N7_BodySizeCommand"

    CommandClassNames(50)="N7CommandManager.N7_ForceSpectatorCommand"
    CommandClassNames(51)="N7CommandManager.N7_KickCommand"
    CommandClassNames(52)="N7CommandManager.N7_BanCommand"
    CommandClassNames(53)="N7CommandManager.N7_TempAdminCommand"

    bZedTimeEnabled=True
    ZedHPConfigThreshold=6
}
