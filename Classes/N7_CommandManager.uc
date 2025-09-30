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
const COMMANDS_COUNT = 100;

var protected const class<N7_Command> CommandsClasses[COMMANDS_COUNT];
var protected const Array<N7_Command> Commands;

/** THP Game settings */
var protected bool bZedTimeEnabled;
var protected float LastAttributeRestoreTime;

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

    for (i = 0; i < COMMANDS_COUNT; i++)
    {
        if (CommandsClasses[i] != None) 
        {
            Commands[i] = new(self) CommandsClasses[i];
        }
    }
}

protected function SaveConfiguration()
{
    local int i;

    self.SaveConfig();

    Colors.SaveConfig();
    Colors.ColorManager.static.StaticSaveConfig();

    for (i = 0; i < COMMANDS_COUNT; i++)
    {
        if (CommandsClasses[i] != None) 
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
    bWaveEnd = (KFGT.bWaveInProgress || KFGT.bWaveBossInProgress) && KFGT.NumMonsters <= 0 && KFGT.TotalMaxMonsters <= 0;

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
    return HPConfigModel.GetZedHPConfigThreshold();
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

    for (i = 0; i < COMMANDS_COUNT; i++)
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

    CommandsClasses(0)=class'N7CommandManager.N7_HelpCommand'
    CommandsClasses(1)=class'N7CommandManager.N7_AdminHelpCommand'
    CommandsClasses(2)=class'N7CommandManager.N7_SlotsCommand'
    CommandsClasses(3)=class'N7CommandManager.N7_SpectatorsCommand'
    CommandsClasses(4)=class'N7CommandManager.N7_FakesCommand'
    CommandsClasses(5)=class'N7CommandManager.N7_ZedHPConfigCommand'
    CommandsClasses(6)=class'N7CommandManager.N7_SpawnRateCommand'
    CommandsClasses(7)=class'N7CommandManager.N7_ZedTimeCommand'
    CommandsClasses(8)=class'N7CommandManager.N7_MaxZedsCommand'
    CommandsClasses(9)=class'N7CommandManager.N7_StatusCommand'

    CommandsClasses(10)=class'N7CommandManager.N7_TradeTimeCommand'
    CommandsClasses(11)=class'N7CommandManager.N7_SkipTradeCommand'
    CommandsClasses(12)=class'N7CommandManager.N7_WaveIntervalCommand'

    CommandsClasses(13)=class'N7CommandManager.N7_SetWaveCommand'
    CommandsClasses(14)=class'N7CommandManager.N7_RestartWaveCommand'
    CommandsClasses(15)=class'N7CommandManager.N7_RespawnPlayerCommand'
    CommandsClasses(16)=class'N7CommandManager.N7_RestoreAttributesCommand'

    CommandsClasses(17)=class'N7CommandManager.N7_ReadyAllCommand'
    CommandsClasses(18)=class'N7CommandManager.N7_ResetStatsCommand'

    CommandsClasses(19)=class'N7CommandManager.N7_RespawnDoorsCommand'
    CommandsClasses(20)=class'N7CommandManager.N7_BreakDoorsCommand'
    CommandsClasses(21)=class'N7CommandManager.N7_WeldDoorsCommand'

    CommandsClasses(22)=class'N7CommandManager.N7_ClearPipesCommand'
    CommandsClasses(23)=class'N7CommandManager.N7_ClearLevelCommand'

    CommandsClasses(24)=class'N7CommandManager.N7_SetNameCommand'
    CommandsClasses(25)=class'N7CommandManager.N7_SetPerkCommand'

    CommandsClasses(26)=class'N7CommandManager.N7_GameSpeedCommand'
    CommandsClasses(27)=class'N7CommandManager.N7_GravityCommand'

    CommandsClasses(28)=class'N7CommandManager.N7_SummonCommand'
    CommandsClasses(29)=class'N7CommandManager.N7_HitZedCommand'
    CommandsClasses(30)=class'N7CommandManager.N7_KillZedsCommand'

    CommandsClasses(31)=class'N7CommandManager.N7_SpawnProjCommand'
    CommandsClasses(32)=class'N7CommandManager.N7_HitPlayerCommand'
    CommandsClasses(33)=class'N7CommandManager.N7_SlapCommand'

    CommandsClasses(34)=class'N7CommandManager.N7_GodModeCommand'
    CommandsClasses(35)=class'N7CommandManager.N7_WalkCommand'
    CommandsClasses(36)=class'N7CommandManager.N7_SpiderCommand'
    CommandsClasses(37)=class'N7CommandManager.N7_FlyCommand'
    CommandsClasses(38)=class'N7CommandManager.N7_GhostCommand'
    CommandsClasses(39)=class'N7CommandManager.N7_BoostCommand'

    CommandsClasses(40)=class'N7CommandManager.N7_InfiniteAmmoCommand'

    CommandsClasses(41)=class'N7CommandManager.N7_GiveWeaponCommand'
    CommandsClasses(42)=class'N7CommandManager.N7_GiveCashCommand'

    CommandsClasses(43)=class'N7CommandManager.N7_TeleportCommand'
    CommandsClasses(44)=class'N7CommandManager.N7_TeleportToCommand'

    CommandsClasses(45)=class'N7CommandManager.N7_HeadSizeCommand'
    CommandsClasses(46)=class'N7CommandManager.N7_BodySizeCommand'

    CommandsClasses(47)=class'N7CommandManager.N7_ForceSpectatorCommand'
    CommandsClasses(48)=class'N7CommandManager.N7_KickCommand'
    CommandsClasses(49)=class'N7CommandManager.N7_BanCommand'
    CommandsClasses(50)=class'N7CommandManager.N7_TempAdminCommand'

    bZedTimeEnabled=True
}
