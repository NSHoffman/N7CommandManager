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

enum ECmd
{
    // Helper Commands
    CMD_HELP,
    CMD_AHELP,
    CMD_STATUS,

    // Game Settings Commands
    CMD_SLOTS,
    CMD_SPECS,
    CMD_FAKED,
    CMD_HPCONFIG,
    CMD_MAXZEDS,
    CMD_SPAWNRATE,
    CMD_SKIPTRADE,
    CMD_TRADE,
    CMD_WAVEINTERVAL,
    CMD_ZEDTIME,
    CMD_GAMESPEED,

    // Gameplay Commands
    CMD_SETWAVE,
    CMD_RESTARTWAVE,
    CMD_RESPAWN,
    CMD_SUMMON,
    CMD_RESTORE,
    CMD_HITZ,
    CMD_KILLZEDS,
    CMD_RESPAWNDOORS,
    CMD_BREAKDOORS,
    CMD_WELDDOORS,
    CMD_SPAWNPROJ,
    CMD_CLEARPIPES,
    CMD_RESETSTATS,
    CMD_READYALL,

    // Player Commands
    CMD_SETNAME,
    CMD_SETPERK,
    CMD_GOD,
    CMD_HEADSIZE,
    CMD_BODYSIZE,
    CMD_HITP,
    CMD_SLAP,
    CMD_TELEPORT,
    CMD_TELEPORTP,
    CMD_GIVEWEAPON,
    CMD_GIVECASH,
    CMD_WALK,
    CMD_SPIDER,
    CMD_FLY,
    CMD_GHOST,
    CMD_FORCESPEC,
    CMD_KICK,
    CMD_BAN,
    CMD_TEMPADMIN,
    CMD_BOOST,
};

/*********************************
 * HELPER COMMANDS
 *********************************/

var protected class<N7_Command> HelpCommandClass;
var protected class<N7_Command> AdminHelpCommandClass;
var protected class<N7_Command> StatusCommandClass;

/*********************************
 * GAME SETTINGS RELATED COMMANDS
 *********************************/

var protected class<N7_Command> SlotsCommandClass;
var protected class<N7_Command> SpecsCommandClass;
var protected class<N7_Command> FakesCommandClass;
var protected class<N7_Command> HPConfigCommandClass;
var protected class<N7_Command> MaxZedsCommandClass;
var protected class<N7_Command> SpawnRateCommandClass;
var protected class<N7_Command> SkipTradeCommandClass;
var protected class<N7_Command> TradeTimeCommandClass;
var protected class<N7_Command> WaveIntervalCommandClass;
var protected class<N7_Command> ZEDTimeCommandClass;
var protected class<N7_Command> GameSpeedCommandClass;

/*********************************
 * GAMEPLAY RELATED COMMANDS
 *********************************/

var protected class<N7_Command> SetWaveCommandClass;
var protected class<N7_Command> RestartWaveCommandClass;
var protected class<N7_Command> RespawnPlayerCommandClass;
var protected class<N7_Command> SummonCommandClass;
var protected class<N7_Command> RestoreAttrsCommandClass;
var protected class<N7_Command> HitZedCommandClass;
var protected class<N7_Command> KillZedsCommandClass;
var protected class<N7_Command> RespawnDoorsCommandClass;
var protected class<N7_Command> BreakDoorsCommandClass;
var protected class<N7_Command> WeldDoorsCommandClass;
var protected class<N7_Command> SpawnProjCommandClass;
var protected class<N7_Command> ClearPipesCommandClass;
var protected class<N7_Command> ResetStatsCommandClass;
var protected class<N7_Command> ReadyAllCommandClass;

/*********************************
 * PLAYERS RELATED COMMANDS
 *********************************/

var protected class<N7_Command> SetNameCommandClass;
var protected class<N7_Command> SetPerkCommandClass;
var protected class<N7_Command> GodModeCommandClass;
var protected class<N7_Command> HeadSizeCommandClass;
var protected class<N7_Command> BodySizeCommandClass;
var protected class<N7_Command> HitPlayerCommandClass;
var protected class<N7_Command> SlapCommandClass;
var protected class<N7_Command> TeleportCommandClass;
var protected class<N7_Command> TeleportToCommandClass;
var protected class<N7_Command> GiveWeaponCommandClass;
var protected class<N7_Command> GiveCashCommandClass;
var protected class<N7_Command> WalkCommandClass;
var protected class<N7_Command> SpiderCommandClass;
var protected class<N7_Command> FlyCommandClass;
var protected class<N7_Command> GhostCommandClass;
var protected class<N7_Command> ForceSpectatorCommandClass;
var protected class<N7_Command> KickCommandClass;
var protected class<N7_Command> BanCommandClass;
var protected class<N7_Command> TempAdminCommandClass;
var protected class<N7_Command> BoostCommandClass;

/** Commands List */
var protected Array<N7_Command> Commands;

/** THP Game settings */
var protected config const bool bAllowMutate;
var protected bool bZedTimeEnabled;

var protected float LastAttributeRestoreTime;
var protected float NextResizedPlayersRefreshTime;

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
 * EVENTS
 *********************************/

event PostBeginPlay()
{
    KFGT = KFGameType(Level.Game);

    if (KFGT == None)
    {
        Destroy();
    }

    GSU         = new(Self) GSUClass;
    Colors      = new(Self) ColorsClass;
    Validator   = new(Self) ValidatorClass;

    HPConfigModel           = new(Self) HPConfigModelClass;
    FakedPlayersModel       = new(Self) FakedPlayersModelClass;
    RestoredPlayersModel    = new(Self) RestoredPlayersModelClass;
    ResizedPlayersModel     = new(Self) ResizedPlayersModelClass;

    InitHelperCommands();
    InitGameSettingsCommands();
    InitGameplayCommands();
    InitPlayerCommands();

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
 * COMMANDS INITIALIZATION
 *********************************/

protected function InitHelperCommands()
{
    Commands[ECmd.CMD_HELP]      = new(Self) HelpCommandClass;
    Commands[ECmd.CMD_AHELP]     = new(Self) AdminHelpCommandClass;
    Commands[ECmd.CMD_STATUS]    = new(Self) StatusCommandClass;
}

protected function InitGameSettingsCommands()
{
    Commands[ECmd.CMD_SLOTS]         = new(Self) SlotsCommandClass;
    Commands[ECmd.CMD_SPECS]         = new(Self) SpecsCommandClass;
    Commands[ECmd.CMD_FAKED]         = new(Self) FakesCommandClass;
    Commands[ECmd.CMD_HPCONFIG]      = new(Self) HPConfigCommandClass;
    Commands[ECmd.CMD_MAXZEDS]       = new(Self) MaxZedsCommandClass;
    Commands[ECmd.CMD_SPAWNRATE]     = new(Self) SpawnRateCommandClass;
    Commands[ECmd.CMD_SKIPTRADE]     = new(Self) SkipTradeCommandClass;
    Commands[ECmd.CMD_TRADE]         = new(Self) TradeTimeCommandClass;
    Commands[ECmd.CMD_WAVEINTERVAL]  = new(Self) WaveIntervalCommandClass;
    Commands[ECmd.CMD_ZEDTIME]       = new(Self) ZEDTimeCommandClass;
    Commands[ECmd.CMD_GAMESPEED]     = new(Self) GameSpeedCommandClass;
}

protected function InitGameplayCommands()
{
    Commands[ECmd.CMD_SETWAVE]      = new(Self) SetWaveCommandClass;
    Commands[ECmd.CMD_RESTARTWAVE]  = new(Self) RestartWaveCommandClass;
    Commands[ECmd.CMD_RESPAWN]      = new(Self) RespawnPlayerCommandClass;
    Commands[ECmd.CMD_SUMMON]       = new(Self) SummonCommandClass;
    Commands[ECmd.CMD_RESTORE]      = new(Self) RestoreAttrsCommandClass;
    Commands[ECmd.CMD_HITZ]         = new(Self) HitZedCommandClass;
    Commands[ECmd.CMD_KILLZEDS]     = new(Self) KillZedsCommandClass;
    Commands[ECmd.CMD_RESPAWNDOORS] = new(Self) RespawnDoorsCommandClass;
    Commands[ECmd.CMD_BREAKDOORS]   = new(Self) BreakDoorsCommandClass;
    Commands[ECmd.CMD_WELDDOORS]    = new(Self) WeldDoorsCommandClass;
    Commands[ECmd.CMD_SPAWNPROJ]    = new(Self) SpawnProjCommandClass;
    Commands[ECmd.CMD_CLEARPIPES]   = new(Self) ClearPipesCommandClass;
    Commands[ECmd.CMD_RESETSTATS]   = new(Self) ResetStatsCommandClass;
    Commands[ECmd.CMD_READYALL]     = new(Self) ReadyAllCommandClass;
}

protected function InitPlayerCommands()
{
    Commands[ECmd.CMD_SETNAME]      = new(Self) SetNameCommandClass;
    Commands[ECmd.CMD_SETPERK]      = new(Self) SetPerkCommandClass;
    Commands[ECmd.CMD_GOD]          = new(Self) GodModeCommandClass;
    Commands[ECmd.CMD_HEADSIZE]     = new(Self) HeadSizeCommandClass;
    Commands[ECmd.CMD_BODYSIZE]     = new(Self) BodySizeCommandClass;
    Commands[ECmd.CMD_HITP]         = new(Self) HitPlayerCommandClass;
    Commands[ECmd.CMD_SLAP]         = new(Self) SlapCommandClass;
    Commands[ECmd.CMD_TELEPORT]     = new(Self) TeleportCommandClass;
    Commands[ECmd.CMD_TELEPORTP]    = new(Self) TeleportToCommandClass;
    Commands[ECmd.CMD_GIVEWEAPON]   = new(Self) GiveWeaponCommandClass;
    Commands[ECmd.CMD_GIVECASH]     = new(Self) GiveCashCommandClass;
    Commands[ECmd.CMD_WALK]         = new(Self) WalkCommandClass;
    Commands[ECmd.CMD_SPIDER]       = new(Self) SpiderCommandClass;
    Commands[ECmd.CMD_FLY]          = new(Self) FlyCommandClass;
    Commands[ECmd.CMD_GHOST]        = new(Self) GhostCommandClass;
    Commands[ECmd.CMD_FORCESPEC]    = new(Self) ForceSpectatorCommandClass;
    Commands[ECmd.CMD_KICK]         = new(Self) KickCommandClass;
    Commands[ECmd.CMD_BAN]          = new(Self) BanCommandClass;
    Commands[ECmd.CMD_TEMPADMIN]    = new(Self) TempAdminCommandClass;
    Commands[ECmd.CMD_BOOST]        = new(Self) BoostCommandClass;
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

    bAllowMutate=True
    bZedTimeEnabled=True

    GSUClass=class'N7_GameStateUtils'
    ColorsClass=class'N7_CommandMessageColors'
    ValidatorClass=class'N7_CommandValidator'

    HPConfigModelClass=class'N7_HPConfigModel'
    FakedPlayersModelClass=class'N7_FakedPlayersModel'
    RestoredPlayersModelClass=class'N7_RestoredPlayersModel'
    ResizedPlayersModelClass=class'N7_ResizedPlayersModel'

    HelpCommandClass=class'N7_HelpCommand'
    AdminHelpCommandClass=class'N7_AdminHelpCommand'
    StatusCommandClass=class'N7_StatusCommand'

    SlotsCommandClass=class'N7_SlotsCommand'
    SpecsCommandClass=class'N7_SpectatorsCommand'
    FakesCommandClass=class'N7_FakesCommand'
    HPConfigCommandClass=class'N7_ZedHPConfigCommand'
    MaxZedsCommandClass=class'N7_MaxZedsCommand'
    SpawnRateCommandClass=class'N7_SpawnRateCommand'
    SkipTradeCommandClass=class'N7_SkipTradeCommand'
    TradeTimeCommandClass=class'N7_TradeTimeCommand'
    WaveIntervalCommandClass=class'N7_WaveIntervalCommand'
    ZEDTimeCommandClass=class'N7_ZedTimeCommand'
    GameSpeedCommandClass=class'N7_GameSpeedCommand'
    SetWaveCommandClass=class'N7_SetWaveCommand'
    RestartWaveCommandClass=class'N7_RestartWaveCommand'

    RespawnPlayerCommandClass=class'N7_RespawnPlayerCommand'
    SummonCommandClass=class'N7_SummonCommand'
    RestoreAttrsCommandClass=class'N7_RestoreAttrsCommand'
    HitZedCommandClass=class'N7_HitZedCommand'
    KillZedsCommandClass=class'N7_KillZedsCommand'
    RespawnDoorsCommandClass=class'N7_RespawnDoorsCommand'
    BreakDoorsCommandClass=class'N7_BreakDoorsCommand'
    WeldDoorsCommandClass=class'N7_WeldDoorsCommand'
    SpawnProjCommandClass=class'N7_SpawnProjCommand'
    ClearPipesCommandClass=class'N7_ClearPipesCommand'
    ResetStatsCommandClass=class'N7_ResetStatsCommand'
    ReadyAllCommandClass=class'N7_ReadyAllCommand'

    SetNameCommandClass=class'N7_SetNameCommand'
    SetPerkCommandClass=class'N7_SetPerkCommand'
    GodModeCommandClass=class'N7_GodModeCommand'
    HeadSizeCommandClass=class'N7_HeadSizeCommand'
    BodySizeCommandClass=class'N7_BodySizeCommand'
    HitPlayerCommandClass=class'N7_HitPlayerCommand'
    SlapCommandClass=class'N7_SlapCommand'
    TeleportCommandClass=class'N7_TeleportCommand'
    TeleportToCommandClass=class'N7_TeleportToCommand'
    GiveWeaponCommandClass=class'N7_GiveWeaponCommand'
    GiveCashCommandClass=class'N7_GiveCashCommand'
    WalkCommandClass=class'N7_WalkCommand'
    SpiderCommandClass=class'N7_SpiderCommand'
    FlyCommandClass=class'N7_FlyCommand'
    GhostCommandClass=class'N7_GhostCommand'
    ForceSpectatorCommandClass=class'N7_ForceSpectatorCommand'
    KickCommandClass=class'N7_KickCommand'
    BanCommandClass=class'N7_BanCommand'
    TempAdminCommandClass=class'N7_TempAdminCommand'
    BoostCommandClass=class'N7_BoostCommand'
}
