class KFTHPCommandManager extends Engine.Mutator;

var KFGameType KFGT;
var KFGameReplicationInfo KFGRI;

/** Class which contains some helper functions to work with game state */
var const Class<KFTHPGameStateUtils> GSUClass;
var KFTHPGameStateUtils GSU;

/*********************************
 * HELPER COMMANDS
 *********************************/

const CMD_HELP = 0;
var protected Class<KFTHPCommand> HelpCommandClass;

const CMD_AHELP = 1;
var protected Class<KFTHPCommand> AdminHelpCommandClass;

const CMD_STATUS = 2;
var protected Class<KFTHPCommand> StatusCommandClass;

/*********************************
 * GAME SETTINGS RELATED COMMANDS
 *********************************/

const CMD_SLOTS = 3;
var protected Class<KFTHPCommand> SlotsCommandClass;

const CMD_SPECS = 4;
var protected Class<KFTHPCommand> SpecsCommandClass;

const CMD_FAKED = 5;
var protected Class<KFTHPCommand> FakesCommandClass;

const CMD_HPCONFIG = 6;
var protected Class<KFTHPCommand> HPConfigCommandClass;

const CMD_MAXZEDS = 7;
var protected Class<KFTHPCommand> MaxZedsCommandClass;

const CMD_SPAWNRATE = 8;
var protected Class<KFTHPCommand> SpawnRateCommandClass;

const CMD_SKIPTRADE = 9;
var protected Class<KFTHPCommand> SkipTradeCommandClass;

const CMD_TRADE = 10;
var protected Class<KFTHPCommand> TradeTimeCommandClass;

const CMD_ZEDTIME = 11;
var protected Class<KFTHPCommand> ZEDTimeCommandClass;

const CMD_GAMESPEED = 12;
var protected Class<KFTHPCommand> GameSpeedCommandClass;

const CMD_SETWAVE = 13;
var protected Class<KFTHPCommand> SetWaveCommandClass;

const CMD_RESTARTWAVE = 14;
var protected Class<KFTHPCommand> RestartWaveCommandClass;

/*********************************
 * GAMEPLAY RELATED COMMANDS
 *********************************/

const CMD_RESPAWN = 15;
// var protected Class<KFTHPCommand> RespawnCommandClass;

const CMD_RESTORE = 16;
// var protected Class<KFTHPCommand> RestoreCommandClass;

const CMD_KILLZEDS = 17;
var protected Class<KFTHPCommand> KillZedsCommandClass;

const CMD_WELDDOORS = 18;
// var protected Class<KFTHPCommand> WeldDoorsCommandClass;

const CMD_CLEARPIPES = 19;
// var protected Class<KFTHPCommand> ClearPipesCommandClass;

/*********************************
 * PLAYERS RELATED COMMANDS
 *********************************/

const CMD_SETNAME = 20;
var protected Class<KFTHPCommand> SetNameCommandClass;

const CMD_GOD = 21;
var protected Class<KFTHPCommand> GodModeCommandClass;

const CMD_HEADSIZE = 22;
// var protected Class<KFTHPCommand> HeadSizeCommandClass;

const CMD_BODYSIZE = 23;
// var protected Class<KFTHPCommand> BodySizeCommandClass;

const CMD_HITP = 24;
// var protected Class<KFTHPCommand> HitPlayerCommandClass;

const CMD_HITZ = 25;
// var protected Class<KFTHPCommand> HitZedCommandClass;

const CMD_TELEPORT = 26;
// var protected Class<KFTHPCommand> TeleportCommandClass;

const CMD_TELEPORTP = 27;
// var protected Class<KFTHPCommand> TeleportToCommandClass;

const CMD_GIVECASH = 28;
// var protected Class<KFTHPCommand> GiveCashCommandClass;

/** Commands List */
var protected Array<KFTHPCommand> Commands;

/** THP Game settings */
var protected config const bool bAllowMutate;
var protected bool bZedTimeDisabled;

var protected int ZedHPConfig;
var protected const int ZedHPConfigThreshold;
var protected int FakedPlayersNum;

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

    SetTimer(5.0, true);
}

event Timer()
{
    /** 
     * Constantly delaying next ZED-Time event
     * so that it will never occur if bZedTimeDisabled is true
     */
    if (IsZedTimeDisabled())
    {
        KFGT.LastZedTimeEvent = Level.TimeSeconds;
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
    Commands[CMD_HELP]      = new(Self) HelpCommandClass;
    Commands[CMD_AHELP]     = new(Self) AdminHelpCommandClass;
    Commands[CMD_STATUS]    = new(Self) StatusCommandClass;
}

protected function InitGameSettingsCommands()
{
    Commands[CMD_SLOTS]         = new(Self) SlotsCommandClass;
    Commands[CMD_SPECS]         = new(Self) SpecsCommandClass;
    Commands[CMD_FAKED]         = new(Self) FakesCommandClass;
    Commands[CMD_HPCONFIG]      = new(Self) HPConfigCommandClass;
    Commands[CMD_MAXZEDS]       = new(Self) MaxZedsCommandClass;
    Commands[CMD_SPAWNRATE]     = new(Self) SpawnRateCommandClass;
    Commands[CMD_SKIPTRADE]     = new(Self) SkipTradeCommandClass;
    Commands[CMD_TRADE]         = new(Self) TradeTimeCommandClass;
    Commands[CMD_ZEDTIME]       = new(Self) ZEDTimeCommandClass;
    Commands[CMD_GAMESPEED]     = new(Self) GameSpeedCommandClass;
    Commands[CMD_SETWAVE]       = new(Self) SetWaveCommandClass;
    Commands[CMD_RESTARTWAVE]   = new(Self) RestartWaveCommandClass;
}

protected function InitGameplayCommands()
{
    // Commands[CMD_RESPAWN]       = new(Self) RespawnCommandClass;
    // Commands[CMD_RESTORE]       = new(Self) RestoreCommandClass;
    Commands[CMD_KILLZEDS]      = new(Self) KillZedsCommandClass;
    // Commands[CMD_WELDDOORS]     = new(Self) WeldDoorsCommandClass;
    // Commands[CMD_CLEARPIPES]    = new(Self) ClearPipesCommandClass;
}

protected function InitPlayerCommands()
{
    Commands[CMD_SETNAME]   = new(Self) SetNameCommandClass;
    Commands[CMD_GOD]       = new(Self) GodModeCommandClass;
    // Commands[CMD_HEADSIZE]  = new(Self) HeadSizeCommandClass;
    // Commands[CMD_BODYSIZE]  = new(Self) BodySizeCommandClass;
    // Commands[CMD_HITP]      = new(Self) HitPlayerCommandClass;
    // Commands[CMD_TELEPORT]  = new(Self) TeleportCommandClass;
    // Commands[CMD_TELEPORTP] = new(Self) TeleportToCommandClass;
    // Commands[CMD_GIVECASH]  = new(Self) GiveCashCommandClass;
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
    ZEDTimeCommandClass=Class'KFTHPZedTimeCommand'
    GameSpeedCommandClass=Class'KFTHPGameSpeedCommand'
    SetWaveCommandClass=Class'KFTHPSetWaveCommand'
    RestartWaveCommandClass=Class'KFTHPRestartWaveCommand'

    // RespawnCommandClass=Class'KFTHPRespawnCommand'
    // RestoreCommandClass=Class'KFTHPRestoreCommand'
    KillZedsCommandClass=Class'KFTHPKillZedsCommand'
    // WeldDoorsCommandClass=Class'KFTHPWeldDoorsCommand'
    // ClearPipesCommandClass=Class'ClearPipesCommand'

    SetNameCommandClass=Class'KFTHPSetNameCommand'
    GodModeCommandClass=Class'KFTHPGodModeCommand'
    // HeadSizeCommandClass=Class'KFTHPHeadSizeCommand'
    // BodySizeCommandClass=Class'KFTHPBodySizeCommand'
    // HitPlayerCommandClass=Class'KFTHPHitPlayerCommand'
    // HitZedCommandClass=Class'KFTHPHitZedCommand'
    // TeleportCommandClass=Class'KFTHPTeleportCommand'
    // TeleportToCommandClass=Class'KFTHPTeleportToCommand'
    // GiveCashCommandClass=Class'KFTHPGiveCashCommand'
}
