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

var protected const class<N7_ResizedPlayersModel> ResizedPlayersModelClass;
var public N7_ResizedPlayersModel ResizedPlayersModel;

var protected const class<N7_HPConfigModel> HPConfigModelClass;
var public N7_HPConfigModel HPConfigModel;

var protected const class<N7_FakedPlayersModel> FakedPlayersModelClass;
var public N7_FakedPlayersModel FakedPlayersModel;

/** Commands List */
const COMMANDS_COUNT = 48;

var protected class<N7_Command> CommandsClasses[COMMANDS_COUNT];
var protected Array<N7_Command> Commands;

/** THP Game settings */
var protected config const bool bAllowMutate;
var protected bool bZedTimeEnabled;

var protected float LastAttributeRestoreTime;
var protected float NextResizedPlayersRefreshTime;

/*********************************
 * INITIALIZATION
 *********************************/

protected function InitServices()
{
    GSU         = new(Self) GSUClass;
    Colors      = new(Self) ColorsClass;
    Validator   = new(Self) ValidatorClass;
}

protected function InitModels()
{
    HPConfigModel           = new(Self) HPConfigModelClass;
    FakedPlayersModel       = new(Self) FakedPlayersModelClass;
    RestoredPlayersModel    = new(Self) RestoredPlayersModelClass;
    ResizedPlayersModel     = new(Self) ResizedPlayersModelClass;
}

protected function InitCommands()
{
    local int i;
    for (i = 0; i < COMMANDS_COUNT; i++)
    {
        Commands[i] = new(Self) CommandsClasses[i];
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

    SetTimer(1.0, True);
}

event Tick(float DeltaTime)
{
    local PlayerController PC;
    local bool bWaveEnd, bWaveStart; 
    local Array<N7_ResizedPlayersModel.ResizedPlayer> ResizedPlayers;
    local int i;

    /**
     * Keeping players' bodies resized
     */
    ResizedPlayers = GetResizedPlayers();
    if (ResizedPlayers.Length > 0)
    {
        if (Level.TimeSeconds >= NextResizedPlayersRefreshTime)
        {
            RefreshResizedPlayers();
            NextResizedPlayersRefreshTime = Level.TimeSeconds + 2.0;
        }

        for (i = 0; i < ResizedPlayers.Length; i++)
        {
            if (ResizedPlayers[i].PC != None)
            {
                GSU.ResizePlayer(ResizedPlayers[i].PC, ResizedPlayers[i].ResizeMultiplier);
            }
        }
    }

    /**
     * Keeping players' attributes restored
     */
    if (GetRestoredPlayers().Length > 0 && Level.TimeSeconds - LastAttributeRestoreTime > 2.0)
    {
        bWaveEnd = (KFGT.bWaveInProgress || KFGT.bWaveBossInProgress)
            && KFGT.NumMonsters <= 0
            && KFGT.TotalMaxMonsters <= 0;

        bWaveStart = KFGT.WaveCountDown == 1
            && !KFGT.bWaveInProgress 
            && !KFGT.bWaveBossInProgress;

        if (bWaveStart || bWaveEnd)
        {
            RefreshRestoredPlayers();

            for (i = 0; i < GetRestoredPlayers().Length; i++)
            {
                PC = GetRestoredPlayers()[i];
                GSU.RestorePlayerAttributes(PC);

                if (PC.Pawn != None && PC.Pawn.Health > 0)
                {
                    PC.ClientMessage("Your attributes have been restored");
                }
            }

            LastAttributeRestoreTime = Level.TimeSeconds;
        }
    }
}

event Timer()
{
    /** 
     * Constantly delaying next ZED-Time event
     * so that it will never occur if bZedTimeEnabled is False
     */
    if (!IsZedTimeEnabled())
    {
        KFGT.LastZedTimeEvent = Level.TimeSeconds;
    }
}

public function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local KFMonster Zed;
    local PlayerController PC;
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

    /** 
     * When new players join the game, they might be added to attribute restoration list
     * That happens in case if all other players already have attribute restoration enabled
     */
    if (PlayerController(Other) != None)
    {
        RefreshRestoredPlayers();
        PC = PlayerController(Other);

        if (KFGT.NumPlayers > 0 &&
            FindRestoredPlayer(PC) == None &&
            GetRestoredPlayers().Length == KFGT.NumPlayers)
        {
            AddRestoredPlayer(PC);
        }
    }

    return True;
}

public function Mutate(string MutateString, PlayerController Sender)
{
    local int MutateCommandIndex;
    local Array<string> MutateArgs;

    if (bAllowMutate)
    {
        Split(MutateString, " ", MutateArgs);

        if (MutateArgs.Length > 0)
        {
            MutateCommandIndex = GetCommandIndex(MutateArgs[0]);
            
            if (MutateCommandIndex != -1)
            {
                Commands[MutateCommandIndex].Execute(Sender, MutateArgs);
            }
        }
    }

    Super.Mutate(MutateString, Sender);
}

/*********************************
 * DATA ACCESSORS
 *********************************/

public final function bool IsMutateAllowed()
{
    return bAllowMutate;
}

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

public final function Array<PlayerController> GetRestoredPlayers()
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

public final function PlayerController FindRestoredPlayer(PlayerController PC)
{
    return RestoredPlayersModel.FindRestoredPlayer(PC);
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

    bAllowMutate=True
    bZedTimeEnabled=True

    GSUClass=class'N7_GameStateUtils'
    ColorsClass=class'N7_CommandMessageColors'
    ValidatorClass=class'N7_CommandValidator'

    HPConfigModelClass=class'N7_HPConfigModel'
    FakedPlayersModelClass=class'N7_FakedPlayersModel'
    RestoredPlayersModelClass=class'N7_RestoredPlayersModel'
    ResizedPlayersModelClass=class'N7_ResizedPlayersModel'

    CommandsClasses(0)=class'N7_HelpCommand'
    CommandsClasses(1)=class'N7_AdminHelpCommand'
    CommandsClasses(2)=class'N7_StatusCommand'

    CommandsClasses(3)=class'N7_SlotsCommand'
    CommandsClasses(4)=class'N7_SpectatorsCommand'
    CommandsClasses(5)=class'N7_FakesCommand'
    CommandsClasses(6)=class'N7_ZedHPConfigCommand'
    CommandsClasses(7)=class'N7_MaxZedsCommand'
    CommandsClasses(8)=class'N7_SpawnRateCommand'
    CommandsClasses(9)=class'N7_SkipTradeCommand'
    CommandsClasses(10)=class'N7_TradeTimeCommand'
    CommandsClasses(11)=class'N7_WaveIntervalCommand'
    CommandsClasses(12)=class'N7_ZedTimeCommand'
    CommandsClasses(13)=class'N7_GameSpeedCommand'
    CommandsClasses(14)=class'N7_SetWaveCommand'
    CommandsClasses(15)=class'N7_RestartWaveCommand'

    CommandsClasses(16)=class'N7_RespawnPlayerCommand'
    CommandsClasses(17)=class'N7_SummonCommand'
    CommandsClasses(18)=class'N7_RestoreAttrsCommand'
    CommandsClasses(19)=class'N7_HitZedCommand'
    CommandsClasses(20)=class'N7_KillZedsCommand'
    CommandsClasses(21)=class'N7_RespawnDoorsCommand'
    CommandsClasses(22)=class'N7_BreakDoorsCommand'
    CommandsClasses(23)=class'N7_WeldDoorsCommand'
    CommandsClasses(24)=class'N7_SpawnProjCommand'
    CommandsClasses(25)=class'N7_ClearPipesCommand'
    CommandsClasses(26)=class'N7_ResetStatsCommand'
    CommandsClasses(27)=class'N7_ReadyAllCommand'

    CommandsClasses(28)=class'N7_SetNameCommand'
    CommandsClasses(29)=class'N7_SetPerkCommand'
    CommandsClasses(30)=class'N7_GodModeCommand'
    CommandsClasses(31)=class'N7_HeadSizeCommand'
    CommandsClasses(32)=class'N7_BodySizeCommand'
    CommandsClasses(33)=class'N7_HitPlayerCommand'
    CommandsClasses(34)=class'N7_SlapCommand'
    CommandsClasses(35)=class'N7_TeleportCommand'
    CommandsClasses(36)=class'N7_TeleportToCommand'
    CommandsClasses(37)=class'N7_GiveWeaponCommand'
    CommandsClasses(38)=class'N7_GiveCashCommand'
    CommandsClasses(39)=class'N7_WalkCommand'
    CommandsClasses(40)=class'N7_SpiderCommand'
    CommandsClasses(41)=class'N7_FlyCommand'
    CommandsClasses(42)=class'N7_GhostCommand'
    CommandsClasses(43)=class'N7_ForceSpectatorCommand'
    CommandsClasses(44)=class'N7_KickCommand'
    CommandsClasses(45)=class'N7_BanCommand'
    CommandsClasses(46)=class'N7_TempAdminCommand'
    CommandsClasses(47)=class'N7_BoostCommand'
}
