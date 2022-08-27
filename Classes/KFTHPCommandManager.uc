class KFTHPCommandManager extends Engine.Mutator;

var KFGameType KFGT;
var KFGameReplicationInfo KFGRI;

/** Class which contains some helper functions to work with game state */
var const Class<KFTHPGameStateUtils> GSUClass;
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
    CMD_RESTORE,
    CMD_KILLZEDS,
    CMD_RESPAWNDOORS,
    CMD_BREAKDOORS,
    CMD_WELDDOORS,
    CMD_CLEARPIPES,

    // Player Commands
    CMD_SETNAME,
    CMD_GOD,
    CMD_HEADSIZE,
    CMD_BODYSIZE,
    CMD_HITP,
    CMD_HITZ,
    CMD_TELEPORT,
    CMD_TELEPORTP,
    CMD_GIVECASH,
    CMD_WALK,
    CMD_SPIDER,
    CMD_FLY,
    CMD_GHOST,
    CMD_FORCESPEC,
    CMD_KICK,
    CMD_BAN,
};

/*********************************
 * HELPER COMMANDS
 *********************************/

var protected Class<KFTHPCommand> HelpCommandClass;
var protected Class<KFTHPCommand> AdminHelpCommandClass;
var protected Class<KFTHPCommand> StatusCommandClass;

/*********************************
 * GAME SETTINGS RELATED COMMANDS
 *********************************/

var protected Class<KFTHPCommand> SlotsCommandClass;
var protected Class<KFTHPCommand> SpecsCommandClass;
var protected Class<KFTHPCommand> FakesCommandClass;
var protected Class<KFTHPCommand> HPConfigCommandClass;
var protected Class<KFTHPCommand> MaxZedsCommandClass;
var protected Class<KFTHPCommand> SpawnRateCommandClass;
var protected Class<KFTHPCommand> SkipTradeCommandClass;
var protected Class<KFTHPCommand> TradeTimeCommandClass;
var protected Class<KFTHPCommand> WaveIntervalCommandClass;
var protected Class<KFTHPCommand> ZEDTimeCommandClass;
var protected Class<KFTHPCommand> GameSpeedCommandClass;

/*********************************
 * GAMEPLAY RELATED COMMANDS
 *********************************/

var protected Class<KFTHPCommand> SetWaveCommandClass;
var protected Class<KFTHPCommand> RestartWaveCommandClass;
var protected Class<KFTHPCommand> RespawnPlayerCommandClass;
var protected Class<KFTHPCommand> RestoreAttrsCommandClass;
var protected Class<KFTHPCommand> KillZedsCommandClass;
var protected Class<KFTHPCommand> RespawnDoorsCommandClass;
var protected Class<KFTHPCommand> BreakDoorsCommandClass;
var protected Class<KFTHPCommand> WeldDoorsCommandClass;
var protected Class<KFTHPCommand> ClearPipesCommandClass;

/*********************************
 * PLAYERS RELATED COMMANDS
 *********************************/

var protected Class<KFTHPCommand> SetNameCommandClass;
var protected Class<KFTHPCommand> GodModeCommandClass;
var protected Class<KFTHPCommand> HeadSizeCommandClass;
var protected Class<KFTHPCommand> BodySizeCommandClass;
// var protected Class<KFTHPCommand> HitPlayerCommandClass;
// var protected Class<KFTHPCommand> HitZedCommandClass;
var protected Class<KFTHPCommand> TeleportCommandClass;
var protected Class<KFTHPCommand> TeleportToCommandClass;
var protected Class<KFTHPCommand> GiveCashCommandClass;
var protected Class<KFTHPCommand> WalkCommandClass;
var protected Class<KFTHPCommand> SpiderCommandClass;
var protected Class<KFTHPCommand> FlyCommandClass;
var protected Class<KFTHPCommand> GhostCommandClass;
// var protected Class<KFTHPCommand> ForceSpectatorCommandClass;
// var protected Class<KFTHPCommand> KickCommandClass;
// var protected Class<KFTHPCommand> BanCommandClass;

/** Commands List */
var protected Array<KFTHPCommand> Commands;

/** THP Game settings */
var protected config const bool bAllowMutate;
var protected bool bZedTimeDisabled;

var protected int ZedHPConfig;
var protected const int ZedHPConfigThreshold;
var protected int FakedPlayersNum;

// Players whose attributes get restored on a regular basis
var protected Array<PlayerController> RestoredPlayers;

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
    Commands[ECmd.CMD_SETWAVE]       = new(Self) SetWaveCommandClass;
    Commands[ECmd.CMD_RESTARTWAVE]   = new(Self) RestartWaveCommandClass;
    Commands[ECmd.CMD_RESPAWN]       = new(Self) RespawnPlayerCommandClass;
    Commands[ECmd.CMD_RESTORE]       = new(Self) RestoreAttrsCommandClass;
    Commands[ECmd.CMD_KILLZEDS]      = new(Self) KillZedsCommandClass;
    Commands[ECmd.CMD_RESPAWNDOORS]  = new(Self) RespawnDoorsCommandClass;
    Commands[ECmd.CMD_BREAKDOORS]    = new(Self) BreakDoorsCommandClass;
    Commands[ECmd.CMD_WELDDOORS]     = new(Self) WeldDoorsCommandClass;
    Commands[ECmd.CMD_CLEARPIPES]    = new(Self) ClearPipesCommandClass;
}

protected function InitPlayerCommands()
{
    Commands[ECmd.CMD_SETNAME]   = new(Self) SetNameCommandClass;
    Commands[ECmd.CMD_GOD]       = new(Self) GodModeCommandClass;
    Commands[ECmd.CMD_HEADSIZE]  = new(Self) HeadSizeCommandClass;
    Commands[ECmd.CMD_BODYSIZE]  = new(Self) BodySizeCommandClass;
    // Commands[ECmd.CMD_HITP]      = new(Self) HitPlayerCommandClass;
    // Commands[ECmd.CMD_HITZ]      = new(Self) HitZedCommandClass;
    Commands[ECmd.CMD_TELEPORT]  = new(Self) TeleportCommandClass;
    Commands[ECmd.CMD_TELEPORTP] = new(Self) TeleportToCommandClass;
    Commands[ECmd.CMD_GIVECASH]  = new(Self) GiveCashCommandClass;
    Commands[ECmd.CMD_WALK]      = new(Self) WalkCommandClass;
    Commands[ECmd.CMD_SPIDER]    = new(Self) SpiderCommandClass;
    Commands[ECmd.CMD_FLY]       = new(Self) FlyCommandClass;
    Commands[ECmd.CMD_GHOST]     = new(Self) GhostCommandClass;
    // Commands[ECmd.CMD_FORCESPEC] = new(Self) ForceSpectatorCommandClass;
    // Commands[ECmd.CMD_KICK]      = new(Self) KickCommandClass;
    // Commands[ECmd.CMD_BAN]       = new(Self) BanCommandClass;
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
    Description="Commands API for KFTHPGameType"

    bAllowMutate=true
    bZedTimeDisabled=false
    ZedHPConfig=1
    ZedHPConfigThreshold=6
    FakedPlayersNum=0

    GSUClass=Class'KFTHPGameStateUtils'

    HelpCommandClass=Class'KFTHPHelpCommand'
    AdminHelpCommandClass=Class'KFTHPAdminHelpCommand'
    StatusCommandClass=Class'KFTHPStatusCommand'

    SlotsCommandClass=Class'KFTHPSlotsCommand'
    SpecsCommandClass=Class'KFTHPSpectatorsCommand'
    FakesCommandClass=Class'KFTHPFakesCommand'
    HPConfigCommandClass=Class'KFTHPZedHPConfigCommand'
    MaxZedsCommandClass=Class'KFTHPMaxZedsCommand'
    SpawnRateCommandClass=Class'KFTHPSpawnRateCommand'
    SkipTradeCommandClass=Class'KFTHPSkipTradeCommand'
    TradeTimeCommandClass=Class'KFTHPTradeTimeCommand'
    WaveIntervalCommandClass=Class'KFTHPWaveIntervalCommand'
    ZEDTimeCommandClass=Class'KFTHPZedTimeCommand'
    GameSpeedCommandClass=Class'KFTHPGameSpeedCommand'
    SetWaveCommandClass=Class'KFTHPSetWaveCommand'
    RestartWaveCommandClass=Class'KFTHPRestartWaveCommand'

    RespawnPlayerCommandClass=Class'KFTHPRespawnPlayerCommand'
    RestoreAttrsCommandClass=Class'KFTHPRestoreAttrsCommand'
    KillZedsCommandClass=Class'KFTHPKillZedsCommand'
    RespawnDoorsCommandClass=Class'KFTHPRespawnDoorsCommand'
    BreakDoorsCommandClass=Class'KFTHPBreakDoorsCommand'
    WeldDoorsCommandClass=Class'KFTHPWeldDoorsCommand'
    ClearPipesCommandClass=Class'KFTHPClearPipesCommand'

    SetNameCommandClass=Class'KFTHPSetNameCommand'
    GodModeCommandClass=Class'KFTHPGodModeCommand'
    HeadSizeCommandClass=Class'KFTHPHeadSizeCommand'
    BodySizeCommandClass=Class'KFTHPBodySizeCommand'
    // HitPlayerCommandClass=Class'KFTHPHitPlayerCommand'
    // HitZedCommandClass=Class'KFTHPHitZedCommand'
    TeleportCommandClass=Class'KFTHPTeleportCommand'
    TeleportToCommandClass=Class'KFTHPTeleportToCommand'
    GiveCashCommandClass=Class'KFTHPGiveCashCommand'
    WalkCommandClass=Class'KFTHPWalkCommand'
    SpiderCommandClass=Class'KFTHPSpiderCommand'
    FlyCommandClass=Class'KFTHPFlyCommand'
    GhostCommandClass=Class'KFTHPGhostCommand'
    // ForceSpectatorCommandClass=Class'KFTHPForceSpectatorCommand'
    // KickCommandClass=Class'KFTHPKickCommand'
    // BanCommandClass=Class'KFTHPBanCommand'
}
