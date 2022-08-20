class KFTHPCommand extends Core.Object within KFTHPCommandManager
    abstract;

const ERRNO_NONE        = 0;
const ERRNO_NOGAMETYPE  = 1;
const ERRNO_GAMESTATE   = 2;
const ERRNO_NOTADMIN    = 3;
const ERRNO_ARGC        = 4;
const ERRNO_ARGL        = 5;
const ERRNO_ARGT        = 6;
const ERRNO_INVALARGS   = 7;
const ERRNO_INVALTARGET = 8;
const ERRNO_CUSTOM      = 9;

var protected const Class<KFTHPCommandValidator> ValidatorClass;
var protected const Class<KFTHPCommandExecutionState> CommandStateClass;

var protected editconstarray Array<string> ArgTypes;
var protected editconstarray Array<string> Aliases;

var protected const int MinArgsNum, MaxArgsNum;

var protected const string Description;
var protected const string Signature;

var protected const bool bNotifySenderOnSuccess;
var protected const bool bNotifyTargetsOnSuccess;
var protected const bool bNotifyGlobalOnSuccess;
var protected const bool bNotifyOnError;

var protected const bool bUseTargets;

var protected config const bool bAdminOnly;
var protected config const bool bDisableNotifications;

/****************************
 *  PUBLIC INTERFACE
 ****************************/

public final function KFTHPCommandExecutionState Execute(
    PlayerController Sender, 
    Array<string> Args)
{
    local KFTHPCommandExecutionState ExecState;

    ExecState = new(Self) CommandStateClass;
    ExecState.InitCommandState(Sender, Args);

    Validate(ExecState);

    if (CheckActionProcessing(ExecState))
    {
        ProcessAction(ExecState);
        FinishExecution(ExecState);
    }
    else
    {
        TerminateExecution(ExecState);
    }

    return ExecState;
}

public final function string GetHelpString()
{
    local int i;
    local string HelpMessage;

    for (i = 0; i < Aliases.Length; i++)
    {
        HelpMessage $= Aliases[i];

        if (i + 1 < Aliases.Length)
        {
            HelpMessage $= "/";
        }
    }

    HelpMessage $= " "$Signature$" - "$Description;

    return HelpMessage;
}

public final function bool IsAdminOnly()
{
    return bAdminOnly;
}

public final function bool HasAlias(string Alias)
{
    local int i;

    for (i = 0; i < Aliases.Length; i++)
    {
        if (Alias ~= Aliases[i])
        {
            return true;
        }
    }

    return false;
}

/****************************
 *  VALIDATION FLOW
 ****************************/

protected final function Validate(KFTHPCommandExecutionState ExecState)
{
    ExecState.SetValidatingStatus();

    StartValidationPipeline(ExecState);

    if (!CheckActionFailure(ExecState))
    {
        ExecState.SetProcessingStatus();
    }
}

protected final function StartValidationPipeline(KFTHPCommandExecutionState ExecState)
{
    ValidateGameType(ExecState);
    ValidateGameState(ExecState);
    ValidateAdmin(ExecState);
    ValidateArgsNum(ExecState);
    ValidateArgsLength(ExecState);
    ValidateArgsTypes(ExecState);
    ValidateArgs(ExecState);
    ValidateTargets(ExecState);
    ValidateCustom(ExecState);
}

protected final function ValidateGameType(KFTHPCommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if (!CheckGameType())
    {
        ExecState.SetErrorNoGameType();
        return;
    }
}

protected final function ValidateGameState(KFTHPCommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if (!CheckGameState())
    {
        ExecState.SetErrorGameState();
        return;
    }
}

protected final function ValidateAdmin(KFTHPCommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if (IsAdminOnly() && !CheckAdminPermissions(ExecState))
    {
        ExecState.SetErrorNotAdmin();
        return;
    }
}

protected final function ValidateArgsNum(KFTHPCommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if (!CheckArgsNum(ExecState))
    {
        ExecState.SetErrorArgC();
        return;
    }
}

protected final function ValidateArgsLength(KFTHPCommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if (!CheckArgsLength(ExecState))
    {
        ExecState.SetErrorArgL();
        return;
    }
}

protected final function ValidateArgsTypes(KFTHPCommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if (!CheckArgTypes(ExecState))
    {
        ExecState.SetErrorArgT();
        return;
    }
}

protected final function ValidateArgs(KFTHPCommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if (!CheckArgs(ExecState))
    {
        ExecState.SetErrorInvalArgs();
        return;
    }
}

protected final function ValidateTargets(KFTHPCommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if (!CheckTargets(ExecState))
    {
        ExecState.SetErrorInvalTarget();
        return;
    }
}

protected final function ValidateCustom(KFTHPCommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if (!CheckCustom(ExecState))
    {
        ExecState.SetErrorCustom();
        return;
    }
}

/****************************
 *  CHECKER FUNCTIONS
 ****************************/

protected final function bool CheckGameType()
{
    return KFGameType(Level.Game) != None && KFGameReplicationInfo(Level.Game.GameReplicationInfo) != None;
}

protected function bool CheckGameState()
{
    return true;
}

protected final function bool CheckActionFailure(KFTHPCommandExecutionState ExecState)
{
    return ExecState.IsFailed();
}

protected final function bool CheckActionProcessing(KFTHPCommandExecutionState ExecState)
{
    return ExecState.IsProcessing();
}

protected final function bool CheckAdminPermissions(KFTHPCommandExecutionState ExecState)
{
    return ExecState.GetSender().Pawn.PlayerReplicationInfo.bAdmin || ExecState.GetSender().Pawn.PlayerReplicationInfo.bSilentAdmin;
}

protected final function bool CheckArgsNum(KFTHPCommandExecutionState ExecState)
{
    return ExecState.GetArgC() >= MinArgsNum && ExecState.GetArgC() <= MaxArgsNum;
}

protected final function bool CheckArgsLength(KFTHPCommandExecutionState ExecState)
{
    local int i;

    for (i = 0; i < ExecState.GetArgC(); i++)
    {
        if (IsEmptyString(ExecState.GetArg(i)) || !IsValidLengthString(ExecState.GetArg(i)))
        {
            return false;
        }
    }

    return true;
}

protected final function bool CheckArgTypes(KFTHPCommandExecutionState ExecState)
{
    local int i;
    local string CurrentArg;

    for (i = 0; i < ExecState.GetArgC(); i++)
    {
        CurrentArg = ExecState.GetArg(i);

        switch (Locs(ArgTypes[i]))
        {
            case "number":
                if (!IsNumber(CurrentArg))
                {
                    return false;
                }
                break;

            case "word":
                if (!IsWord(CurrentArg))
                {
                    return false;
                }
                break;

            case "switch":
                if (!IsSwitchValue(CurrentArg))
                {
                    return false;
                }
                break;

            case "any":
                break;
        }
    }

    return true;
}

protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    return true;
}

protected function bool CheckTargets(KFTHPCommandExecutionState ExecState)
{
    return true;
}

protected function bool CheckCustom(KFTHPCommandExecutionState ExecState)
{
    return true;
}

/****************************
 *  ACTION PROCESSING
 ****************************/

protected final function ProcessAction(KFTHPCommandExecutionState ExecState)
{
    if (bUseTargets)
    {
        AddCommandActionTargets(ExecState);
    }

    DoAction(ExecState);

    ExecState.RestoreArgs();
    ExecState.SetSuccessStatus();
}

protected function DoAction(KFTHPCommandExecutionState ExecState);

protected function DoActionForSingleTarget(KFTHPCommandExecutionState ExecState, PlayerController PC);

protected final function TerminateExecution(KFTHPCommandExecutionState ExecState)
{
    if (!bDisableNotifications)
    {
        NotifyOnError(ExecState);
    }
}

protected final function FinishExecution(KFTHPCommandExecutionState ExecState)
{
    if (!bDisableNotifications)
    {
        NotifyOnSuccess(ExecState);
    }
}

/****************************
 *  ACTION TARGET MANAGEMENT
 ****************************/

protected final function AddCommandActionTargets(KFTHPCommandExecutionState ExecState)
{
    local Controller C;
    local PlayerController PC;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        PC = PlayerController(C);

        if (PC != None && ShouldBeTarget(ExecState, PC))
        {
            ExecState.AddTarget(PC);

            if (ExecState.ShouldStopTargetSearch())
            {
                break;
            }
        }
    }
}

protected function bool ShouldBeTarget(
    KFTHPCommandExecutionState ExecState, 
    PlayerController PC)
{
    return false;
}

/****************************
 *  NOTIFICATIONS
 ****************************/

protected final function SendMessage(PlayerController PC, string Message)
{
    PC.ClientMessage(Message);
}

protected final function NotifyOnSuccess(KFTHPCommandExecutionState ExecState)
{
    if (bNotifySenderOnSuccess)
    {
        NotifySenderOnSuccess(ExecState);
    }

    if (bNotifyTargetsOnSuccess)
    {
        NotifyTargetsOnSuccess(ExecState);
    }

    if (bNotifyGlobalOnSuccess)
    {
        NotifyGlobalOnSuccess(ExecState);
    }
}

protected final function NotifySenderOnSuccess(KFTHPCommandExecutionState ExecState)
{
    SendMessage(ExecState.GetSender(), GetSenderSuccessMessage(ExecState));
}

protected final function NotifyTargetsOnSuccess(KFTHPCommandExecutionState ExecState)
{
    local int i;

    for (i = 0; i < ExecState.GetTargetsNum(); i++)
    {
        if (bNotifySenderOnSuccess && ExecState.GetTarget(i) == ExecState.GetSender())
        {
            continue;
        }

        SendMessage(ExecState.GetTarget(i), GetTargetSuccessMessage(ExecState));
    }
}

protected final function NotifyGlobalOnSuccess(KFTHPCommandExecutionState ExecState)
{
    local Controller C;
    local PlayerController PC;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        PC = PlayerController(C);

        if (PC != None)
        {
            if (
                bNotifySenderOnSuccess && PC == ExecState.GetSender() ||
                bNotifyTargetsOnSuccess && ExecState.IsTarget(PC))
            {
                continue;
            }

            SendMessage(PC, GetGlobalSuccessMessage(ExecState));
        }
    }
}

protected final function NotifyOnError(KFTHPCommandExecutionState ExecState)
{
    if (bNotifyOnError)
    {
        SendMessage(ExecState.GetSender(), GetErrorMessage(ExecState));
    }
}

protected function string GetSenderSuccessMessage(KFTHPCommandExecutionState ExecState);

protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState);

protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState);

protected function string GetErrorMessage(KFTHPCommandExecutionState ExecState)
{
    switch (ExecState.GetErrNo())
    {
        case ERRNO_NOGAMETYPE:
            return Error(NoGameTypeMessage());

        case ERRNO_GAMESTATE:
            return Error(InvalidGameStateMessage());
        
        case ERRNO_NOTADMIN:
            return Error(NotAdminMessage());

        case ERRNO_ARGC:
            return Error(InvalidArgsNumMessage(ExecState.GetArgC()));

        case ERRNO_ARGL:
            return Error(InvalidArgsLengthMessage());

        case ERRNO_ARGT:
            return Error(InvalidArgTypesMessage());

        case ERRNO_INVALARGS:
            return Error(InvalidArgsMessage(ExecState));

        case ERRNO_INVALTARGET:
            return Error(InvalidTargetMessage(ExecState));

        case ERRNO_CUSTOM:
            return Error(CustomErrorMessage(ExecState));

        default:
            return Error(UnexpectedErrorMessage());
    }
}

/****************************
 *  ERROR MESSAGES
 ****************************/

protected final function string Error(string Message)
{
    return "Error: "$Message;
}

protected final function string NoGameTypeMessage()
{
    return "KFGameType/KFGameReplicationInfo not found";
}

protected function string InvalidGameStateMessage()
{
    return "Command cannot be executed at current game state";
}

protected final function string NotAdminMessage()
{
    return "Admin access required";
}

protected final function string InvalidArgsNumMessage(int ArgsActual)
{
    if (MinArgsNum == MaxArgsNum)
    {
        return "Expected "$MaxArgsNum$" arguments but got "$ArgsActual;
    }

    return "Expected from "$MinArgsNum$" to "$MaxArgsNum$" arguments but got "$ArgsActual;
}

protected final function string InvalidArgsLengthMessage()
{
    return "Arguments cannot be empty and must not exceed "$GetMaxAcceptableStringLength()$" characters in length";
}

protected final function string InvalidArgTypesMessage()
{
    return "Command arguments must match the signature "$Signature;
}

protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "Invalid arguments";
}

protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return "Invalid target";
}

protected function string CustomErrorMessage(KFTHPCommandExecutionState ExecState)
{
    return "Custom Error";
}

protected final function string UnexpectedErrorMessage()
{
    return "Unexpected Error";
}

/****************************
 *  ARGS COERCION UTILS
 ****************************/

protected final function int ToInt(string Arg)
{
    return int(Arg);
}

protected final function float ToFloat(string Arg)
{
    return float(Arg);
}

protected final function string ToString(int Arg)
{
    return string(Arg);
}

protected final function string ToStringF(float Arg)
{
    return string(Arg);
}

/****************************
 *  VALIDATION UTILS
 ****************************/

protected final function int GetMaxAcceptableStringLength()
{
    return ValidatorClass.static.GetMaxAcceptableStringLength();
}

protected final function bool IsEmptyString(string Str)
{
    return ValidatorClass.static.IsEmptyString(Str);
}

protected final function bool IsValidLengthString(string Str)
{
    return ValidatorClass.static.IsValidLengthString(Str);
}

protected final function bool IsStringPartOf(string SubStr, string SupStr)
{
    return ValidatorClass.static.IsStringPartOf(SubStr, SupStr);
}

protected final function bool IsLetter(string Str)
{
    return ValidatorClass.static.IsLetter(Str);
}

protected final function bool IsWord(string Str)
{
    return ValidatorClass.static.IsWord(Str);
}

protected final function bool IsSwitchOnValue(string Value)
{
    return ValidatorClass.static.IsSwitchOnValue(Value);
}

protected final function bool IsSwitchOffValue(string Value)
{
    return ValidatorClass.static.IsSwitchOffValue(Value);
}

protected final function bool IsSwitchValue(string Value)
{
    return ValidatorClass.static.IsSwitchValue(Value);
}

protected final function bool IsDigit(string Str)
{
    return ValidatorClass.static.IsDigit(Str);
}

protected final function bool IsNumber(string Str)
{
    return ValidatorClass.static.IsNumber(Str);
}

protected final function bool IsInRange(
    coerce int Number, 
    int Start, 
    optional int End)
{
    return ValidatorClass.static.IsInRange(Number, Start, End);
}

protected final function bool IsInRangeF(
    coerce float Number, 
    float Start, 
    optional float End)
{
    return ValidatorClass.static.IsInRangeF(Number, Start, End);
}

protected final function bool IsPlayer(Controller C)
{
    return ValidatorClass.static.IsPlayer(C);
}

protected final function bool IsAlive(PlayerController PC)
{
    return ValidatorClass.static.IsAlive(PC);
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=0
    bAdminOnly=false
    bNotifyOnError=true
    bNotifySenderOnSuccess=true
    bNotifyTargetsOnSuccess=false
    bNotifyGlobalOnSuccess=false
    bDisableNotifications=false
    bUseTargets=false
    CommandStateClass=Class'KFTHPCommandExecutionState'
    ValidatorClass=Class'KFTHPCommandValidator'
}
