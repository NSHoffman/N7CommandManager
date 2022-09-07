class KFTHPCommandManager extends Engine.Mutator;

var KFGameType KFGT;

/** Class which contains some helper functions to work with game state */
var const class<KFTHPGameStateUtils> GSUClass;
var KFTHPGameStateUtils GSU;

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
};

/*********************************
 * HELPER COMMANDS
 *********************************/

var protected class<KFTHPCommand> HelpCommandClass;
var protected class<KFTHPCommand> AdminHelpCommandClass;
var protected class<KFTHPCommand> StatusCommandClass;

/*********************************
 * GAME SETTINGS RELATED COMMANDS
 *********************************/

var protected class<KFTHPCommand> SlotsCommandClass;
var protected class<KFTHPCommand> SpecsCommandClass;
var protected class<KFTHPCommand> FakesCommandClass;
var protected class<KFTHPCommand> HPConfigCommandClass;
var protected class<KFTHPCommand> MaxZedsCommandClass;
var protected class<KFTHPCommand> SpawnRateCommandClass;
var protected class<KFTHPCommand> SkipTradeCommandClass;
var protected class<KFTHPCommand> TradeTimeCommandClass;
var protected class<KFTHPCommand> WaveIntervalCommandClass;
var protected class<KFTHPCommand> ZEDTimeCommandClass;
var protected class<KFTHPCommand> GameSpeedCommandClass;

/*********************************
 * GAMEPLAY RELATED COMMANDS
 *********************************/

var protected class<KFTHPCommand> SetWaveCommandClass;
var protected class<KFTHPCommand> RestartWaveCommandClass;
var protected class<KFTHPCommand> RespawnPlayerCommandClass;
var protected class<KFTHPCommand> SummonCommandClass;
var protected class<KFTHPCommand> RestoreAttrsCommandClass;
var protected class<KFTHPCommand> HitZedCommandClass;
var protected class<KFTHPCommand> KillZedsCommandClass;
var protected class<KFTHPCommand> RespawnDoorsCommandClass;
var protected class<KFTHPCommand> BreakDoorsCommandClass;
var protected class<KFTHPCommand> WeldDoorsCommandClass;
var protected class<KFTHPCommand> SpawnProjCommandClass;
var protected class<KFTHPCommand> ClearPipesCommandClass;
var protected class<KFTHPCommand> ResetStatsCommandClass;
var protected class<KFTHPCommand> ReadyAllCommandClass;

/*********************************
 * PLAYERS RELATED COMMANDS
 *********************************/

var protected class<KFTHPCommand> SetNameCommandClass;
var protected class<KFTHPCommand> SetPerkCommandClass;
var protected class<KFTHPCommand> GodModeCommandClass;
var protected class<KFTHPCommand> HeadSizeCommandClass;
var protected class<KFTHPCommand> BodySizeCommandClass;
var protected class<KFTHPCommand> HitPlayerCommandClass;
var protected class<KFTHPCommand> SlapCommandClass;
var protected class<KFTHPCommand> TeleportCommandClass;
var protected class<KFTHPCommand> TeleportToCommandClass;
var protected class<KFTHPCommand> GiveWeaponCommandClass;
var protected class<KFTHPCommand> GiveCashCommandClass;
var protected class<KFTHPCommand> WalkCommandClass;
var protected class<KFTHPCommand> SpiderCommandClass;
var protected class<KFTHPCommand> FlyCommandClass;
var protected class<KFTHPCommand> GhostCommandClass;
var protected class<KFTHPCommand> ForceSpectatorCommandClass;
var protected class<KFTHPCommand> KickCommandClass;
var protected class<KFTHPCommand> BanCommandClass;
var protected class<KFTHPCommand> TempAdminCommandClass;

/** Commands List */
var protected Array<KFTHPCommand> Commands;

/** THP Game settings */
var protected config const bool bAllowMutate;
var protected bool bZedTimeDisabled;

// Minimum ZED HP config that can be set when there are more players
var protected const int ZedHPConfigThreshold;
var protected int ZedHPConfig;
var protected int FakedPlayersNum;

// Players whose attributes get restored on a regular basis
var protected Array<PlayerController> RestoredPlayers;

// Players whose body size scaling needs to be tracked
struct ResizedPlayer
{
    var PlayerController PC;
    var float ResizeMultiplier;
};
var protected Array<ResizedPlayer> ResizedPlayers;
var protected float NextResizedPlayersRefreshTime;

/*********************************
 * DATA ACCESSORS
 *********************************/

public final function bool IsMutateAllowed()
{
    return bAllowMutate;
}

public final function bool IsZedTimeDisabled()
{
    return bZedTimeDisabled;
}

public final function SetZedTime(bool Flag)
{
    bZedTimeDisabled = Flag;
}

public final function int GetZedHPConfig()
{
    return ZedHPConfig;
}

public final function int GetZedHPConfigThreshold()
{
    return ZedHPConfigThreshold;
}

public final function SetZedHPConfig(int NewZedHPConfig)
{
    ZedHPConfig = NewZedHPConfig;
}

public final function int GetFakedPlayersNum()
{
    return FakedPlayersNum;
}

public final function SetFakedPlayersNum(int NewFakedPlayersNum)
{
    FakedPlayersNum = NewFakedPlayersNum;
}

public final function Array<PlayerController> GetRestoredPlayers()
{
    return RestoredPlayers;
}

public final function RefreshRestoredPlayers()
{
    local PlayerController CurrentPC;
    local int i;

    while (i < RestoredPlayers.Length)
    {
        CurrentPC = RestoredPlayers[i];
        if (CurrentPC == None)
        {
            RestoredPlayers.Remove(i, 1);
            break;
        }
        i++;
    }
}

public final function AddRestoredPlayer(PlayerController PC)
{
    local PlayerController CurrentPC;
    local int i;

    for (i = 0; i < RestoredPlayers.Length; i++)
    {
        CurrentPC = RestoredPlayers[i];
        if (CurrentPC == PC)
        {
            return;
        }
    }

    RestoredPlayers[RestoredPlayers.Length] = PC;
}

public final function RemoveRestoredPlayer(PlayerController PC)
{
    local PlayerController CurrentPC;
    local int i;

    for (i = 0; i < RestoredPlayers.Length; i++)
    {
        CurrentPC = RestoredPlayers[i];
        if (CurrentPC == PC)
        {
            RestoredPlayers.Remove(i, 1);
            return;
        }
    }
}

public final function Array<ResizedPlayer> GetResizedPlayers()
{
    return ResizedPlayers;
}

public final function RefreshResizedPlayers()
{
    local int i;

    while (i < ResizedPlayers.Length)
    {
        if (ResizedPlayers[i].PC == None || 
            ResizedPlayers[i].PC.Pawn == None || 
            ResizedPlayers[i].PC.Pawn.Health <= 0 || 
            ResizedPlayers[i].ResizeMultiplier == 1.0)
        {
            ResizedPlayers.Remove(i, 1);
            break;
        }
        i++;
    }
}

public final function AddResizedPlayer(PlayerController PC, float ResizeMultiplier)
{
    local ResizedPlayer NewPlayer;
    local int i;

    NewPlayer.PC = PC;
    NewPlayer.ResizeMultiplier = ResizeMultiplier;

    for (i = 0; i < ResizedPlayers.Length; i++)
    {
        if (ResizedPlayers[i].PC == PC)
        {
            ResizedPlayers[i].ResizeMultiplier = ResizeMultiplier;
            return;
        }
    }

    ResizedPlayers[ResizedPlayers.Length] = NewPlayer;
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

    GSU = new(Self) GSUClass;

    InitHelperCommands();
    InitGameSettingsCommands();
    InitGameplayCommands();
    InitPlayerCommands();

    SetTimer(1.0, true);
}

event Tick(float DeltaTime)
{
    local int i;

    if (ResizedPlayers.Length > 0)
    {
        for (i = 0; i < ResizedPlayers.Length; i++)
        {
            if (ResizedPlayers[i].PC != None)
            {
                GSU.ResizePlayer(ResizedPlayers[i].PC, ResizedPlayers[i].ResizeMultiplier);
            }
        }

        if (Level.TimeSeconds >= NextResizedPlayersRefreshTime)
        {
            RefreshResizedPlayers();
            NextResizedPlayersRefreshTime = Level.TimeSeconds + 1;
        }
    }
}

event Timer()
{
    local PlayerController PC;
    local int i;

    /** 
     * Constantly delaying next ZED-Time event
     * so that it will never occur if bZedTimeDisabled is true
     */
    if (IsZedTimeDisabled())
    {
        KFGT.LastZedTimeEvent = Level.TimeSeconds;
    }

    if (KFGT.WaveCountDown == KFGT.TimeBetweenWaves || KFGT.WaveCountDown == 5)
    {
        RefreshRestoredPlayers();

        for (i = 0; i < RestoredPlayers.Length; i++)
        {
            PC = RestoredPlayers[i];
            GSU.RestorePlayerAttributes(PC);

            if (PC.Pawn != None && PC.Pawn.Health > 0)
            {
                PC.ClientMessage("Your attributes have been restored");
            }
        }
    }
}

public function bool CheckReplacement(Actor Other, out byte bSuperRelevant)
{
    local KFMonster Zed;

    /** 
     * Changing Monsters HP modifiers depending on
     * current HP config and number of players alive
     */
    if (KFMonster(Other) != None)
    {
        Zed = KFMonster(Other);

        Zed.Health = GSU.GetZedModifiedHealth(Zed);
        Zed.HealthMax = GSU.GetZedModifiedHealth(Zed);
        Zed.HeadHealth = GSU.GetZedModifiedHeadHealth(Zed);
    }

    return true;
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
    GroupName="KF-THPCommandManager"
    FriendlyName="N7 Three Hundred Pounds Command Manager"
    Description="Mutate API for more sophisticated game settings and event triggering."

    bAllowMutate=true
    bZedTimeDisabled=false
    ZedHPConfig=1
    ZedHPConfigThreshold=6
    FakedPlayersNum=0

    GSUClass=class'KFTHPGameStateUtils'

    HelpCommandClass=class'KFTHPHelpCommand'
    AdminHelpCommandClass=class'KFTHPAdminHelpCommand'
    StatusCommandClass=class'KFTHPStatusCommand'

    SlotsCommandClass=class'KFTHPSlotsCommand'
    SpecsCommandClass=class'KFTHPSpectatorsCommand'
    FakesCommandClass=class'KFTHPFakesCommand'
    HPConfigCommandClass=class'KFTHPZedHPConfigCommand'
    MaxZedsCommandClass=class'KFTHPMaxZedsCommand'
    SpawnRateCommandClass=class'KFTHPSpawnRateCommand'
    SkipTradeCommandClass=class'KFTHPSkipTradeCommand'
    TradeTimeCommandClass=class'KFTHPTradeTimeCommand'
    WaveIntervalCommandClass=class'KFTHPWaveIntervalCommand'
    ZEDTimeCommandClass=class'KFTHPZedTimeCommand'
    GameSpeedCommandClass=class'KFTHPGameSpeedCommand'
    SetWaveCommandClass=class'KFTHPSetWaveCommand'
    RestartWaveCommandClass=class'KFTHPRestartWaveCommand'

    RespawnPlayerCommandClass=class'KFTHPRespawnPlayerCommand'
    SummonCommandClass=class'KFTHPSummonCommand'
    RestoreAttrsCommandClass=class'KFTHPRestoreAttrsCommand'
    HitZedCommandClass=class'KFTHPHitZedCommand'
    KillZedsCommandClass=class'KFTHPKillZedsCommand'
    RespawnDoorsCommandClass=class'KFTHPRespawnDoorsCommand'
    BreakDoorsCommandClass=class'KFTHPBreakDoorsCommand'
    WeldDoorsCommandClass=class'KFTHPWeldDoorsCommand'
    SpawnProjCommandClass=class'KFTHPSpawnProjCommand'
    ClearPipesCommandClass=class'KFTHPClearPipesCommand'
    ResetStatsCommandClass=class'KFTHPResetStatsCommand'
    ReadyAllCommandClass=class'KFTHPReadyAllCommand'

    SetNameCommandClass=class'KFTHPSetNameCommand'
    SetPerkCommandClass=class'KFTHPSetPerkCommand'
    GodModeCommandClass=class'KFTHPGodModeCommand'
    HeadSizeCommandClass=class'KFTHPHeadSizeCommand'
    BodySizeCommandClass=class'KFTHPBodySizeCommand'
    HitPlayerCommandClass=class'KFTHPHitPlayerCommand'
    SlapCommandClass=class'KFTHPSlapCommand'
    TeleportCommandClass=class'KFTHPTeleportCommand'
    TeleportToCommandClass=class'KFTHPTeleportToCommand'
    GiveWeaponCommandClass=class'KFTHPGiveWeaponCommand'
    GiveCashCommandClass=class'KFTHPGiveCashCommand'
    WalkCommandClass=class'KFTHPWalkCommand'
    SpiderCommandClass=class'KFTHPSpiderCommand'
    FlyCommandClass=class'KFTHPFlyCommand'
    GhostCommandClass=class'KFTHPGhostCommand'
    ForceSpectatorCommandClass=class'KFTHPForceSpectatorCommand'
    KickCommandClass=class'KFTHPKickCommand'
    BanCommandClass=class'KFTHPBanCommand'
    TempAdminCommandClass=class'KFTHPTempAdminCommand'
}
