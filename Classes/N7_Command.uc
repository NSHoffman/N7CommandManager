class N7_Command extends Core.Object within N7_CommandManager
    abstract;

const ERRNO_NONE        = 0;
const ERRNO_NOGAMETYPE  = 1;
const ERRNO_GAMESTATE   = 2;
const ERRNO_SENDER      = 3;
const ERRNO_NOTADMIN    = 4;
const ERRNO_ARGC        = 5;
const ERRNO_ARGL        = 6;
const ERRNO_ARGT        = 7;
const ERRNO_INVALARGS   = 8;
const ERRNO_INVALTARGET = 9;
const ERRNO_CUSTOM      = 10;
const ERRNO_RUNTIME     = 11;

var protected const class<N7_CommandValidator> ValidatorClass;
var protected const class<N7_CommandExecutionState> CommandStateClass;

var protected editconstarray Array<string> ArgTypes;
var protected editconstarray Array<string> Aliases;

var protected const int MinArgsNum, MaxArgsNum;

var protected const string Description;
var protected const string Signature;

var protected const bool bNotifySenderOnSuccess;
var protected const bool bNotifyTargetsOnSuccess;
var protected const bool bNotifyGlobalOnSuccess;
var protected const bool bNotifyAdminsOnlyOnSuccess;
var protected const bool bNotifyOnError;

var protected const bool bUseTargets;

var protected const bool bOnlyPlayerSender;
var protected const bool bOnlyAliveSender;

var protected config const bool bAdminOnly;
var protected config const bool bDisableNotifications;

/****************************
 *  PUBLIC INTERFACE
 ****************************/

public final function Execute(
    PlayerController Sender, Array<string> Args)
{
    local N7_CommandExecutionState ExecState;

    ExecState = new(Self) CommandStateClass;
    ExecState.InitCommandState(Sender, Args);

    Validate(ExecState);

    if (CheckActionProcessing(ExecState))
    {
        ProcessAction(ExecState);   
    }

    if (CheckActionSuccess(ExecState))
    {
        FinishExecution(ExecState);
    }
    else
    {
        TerminateExecution(ExecState);
    }
    Cleanup();
}

public final function GetHelp(PlayerController PC)
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
    
    SendMessage(PC, HelpMessage);
}

public function GetExtendedHelp(PlayerController PC);

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

protected final function Validate(N7_CommandExecutionState ExecState)
{
    ExecState.SetValidatingStatus();

    StartValidationPipeline(ExecState);

    if (!CheckActionFailure(ExecState))
    {
        ExecState.SetProcessingStatus();
    }
}

protected final function StartValidationPipeline(N7_CommandExecutionState ExecState)
{
    ValidateGameType(ExecState);
    ValidateGameState(ExecState);
    ValidateSender(ExecState);
    ValidateArgsNum(ExecState);
    ValidateArgsLength(ExecState);
    ValidateArgsTypes(ExecState);
    ValidateArgs(ExecState);
    ValidateTargets(ExecState);
    ValidateAdmin(ExecState);
    ValidateCustom(ExecState);
}

protected final function ValidateGameType(N7_CommandExecutionState ExecState)
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

protected final function ValidateGameState(N7_CommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if (!CheckGameState(ExecState))
    {
        ExecState.SetErrorGameState();
        return;
    }
}

protected final function ValidateSender(N7_CommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if (!CheckSender(ExecState))
    {
        ExecState.SetErrorSender();
        return;
    }
}

protected final function ValidateArgsNum(N7_CommandExecutionState ExecState)
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

protected final function ValidateArgsLength(N7_CommandExecutionState ExecState)
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

protected final function ValidateArgsTypes(N7_CommandExecutionState ExecState)
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

protected final function ValidateArgs(N7_CommandExecutionState ExecState)
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

protected final function ValidateTargets(N7_CommandExecutionState ExecState)
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

protected final function ValidateAdmin(N7_CommandExecutionState ExecState)
{
    if (CheckActionFailure(ExecState))
    {
        return;
    }

    if ((IsAdminOnly() || !CheckIfNonAdminExecutionAllowed(ExecState)) && !CheckAdminPermissions(ExecState))
    {
        ExecState.SetErrorNotAdmin();
        return;
    }
}

protected final function ValidateCustom(N7_CommandExecutionState ExecState)
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

protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return true;
}

protected function bool CheckSender(N7_CommandExecutionState ExecState)
{
    if ((bOnlyAliveSender || !IsAdmin(ExecState.GetSender())) && IsSpectator(ExecState.GetSender()) && bOnlyPlayerSender)
    {
        return false;
    }

    if (bOnlyAliveSender && !IsAlive(ExecState.GetSender()))
    {
        return false;
    }

    return true;
}

protected final function bool CheckActionProcessing(N7_CommandExecutionState ExecState)
{
    return ExecState.IsProcessing();
}

protected final function bool CheckActionSuccess(N7_CommandExecutionState ExecState)
{
    return ExecState.IsSuccess();
}

protected final function bool CheckActionFailure(N7_CommandExecutionState ExecState)
{
    return ExecState.IsFailed();
}

protected final function bool CheckAdminPermissions(N7_CommandExecutionState ExecState)
{
    return IsAdmin(ExecState.GetSender()) || IsTempAdmin(ExecState.GetSender());
}

protected final function bool CheckArgsNum(N7_CommandExecutionState ExecState)
{
    return ExecState.GetArgC() >= MinArgsNum && ExecState.GetArgC() <= MaxArgsNum;
}

protected final function bool CheckArgsLength(N7_CommandExecutionState ExecState)
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

protected final function bool CheckArgTypes(N7_CommandExecutionState ExecState)
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

protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    return true;
}

protected function bool CheckTargets(N7_CommandExecutionState ExecState)
{
    return true;
}

/** Special check in case a command requires admin access under certain circumstances */
protected function bool CheckIfNonAdminExecutionAllowed(N7_CommandExecutionState ExecState)
{
    return true;
}

protected function bool CheckCustom(N7_CommandExecutionState ExecState)
{
    return true;
}

/****************************
 *  ACTION PROCESSING
 ****************************/

protected final function ProcessAction(N7_CommandExecutionState ExecState)
{
    if (bUseTargets)
    {
        AddCommandActionTargets(ExecState);
    }

    DoAction(ExecState);
    ExecState.RestoreArgs();

    if (!CheckActionFailure(ExecState))
    {
        ExecState.SetSuccessStatus();
    }
}

protected function DoAction(N7_CommandExecutionState ExecState);

protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC);

protected final function TerminateExecution(N7_CommandExecutionState ExecState)
{
    if (!bDisableNotifications)
    {
        NotifyOnError(ExecState);
    }
}

protected final function FinishExecution(N7_CommandExecutionState ExecState)
{
    if (!bDisableNotifications)
    {
        NotifyOnSuccess(ExecState);
    }
}

protected function Cleanup();

/****************************
 *  ACTION TARGET MANAGEMENT
 ****************************/

protected final function AddCommandActionTargets(N7_CommandExecutionState ExecState)
{
    local Controller C;
    local PlayerController PC;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        PC = PlayerController(C);

        if (IsPlayer(PC) && ShouldBeTarget(ExecState, PC))
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
    N7_CommandExecutionState ExecState, 
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

protected final function string GetInstigatorName(N7_CommandExecutionState ExecState)
{
    return ExecState.GetSender().PlayerReplicationInfo.PlayerName;
}

protected final function NotifyOnSuccess(N7_CommandExecutionState ExecState)
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

protected final function NotifySenderOnSuccess(N7_CommandExecutionState ExecState)
{
    SendMessage(ExecState.GetSender(), GetSenderSuccessMessage(ExecState));
}

protected final function NotifyTargetsOnSuccess(N7_CommandExecutionState ExecState)
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

protected final function NotifyGlobalOnSuccess(N7_CommandExecutionState ExecState)
{
    local Controller C;
    local PlayerController PC;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        PC = PlayerController(C);

        if (PC != None && (!bNotifyAdminsOnlyOnSuccess || IsAdmin(PC)))
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

protected final function NotifyOnError(N7_CommandExecutionState ExecState)
{
    if (bNotifyOnError)
    {
        SendMessage(ExecState.GetSender(), GetErrorMessage(ExecState));
    }
}

protected function string GetSenderSuccessMessage(N7_CommandExecutionState ExecState);

protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState);

protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState);

protected function string GetErrorMessage(N7_CommandExecutionState ExecState)
{
    switch (ExecState.GetErrNo())
    {
        case ERRNO_NOGAMETYPE:
            return Error(NoGameTypeMessage());

        case ERRNO_GAMESTATE:
            return Error(InvalidGameStateMessage());

        case ERRNO_SENDER:
            return Error(InvalidSenderMessage());
        
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

        case ERRNO_RUNTIME:
            return Error(RuntimeErrorMessage(ExecState));

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

protected function string InvalidSenderMessage()
{
    return "Command is not available for spectators";
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

protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Invalid arguments";
}

protected function string InvalidTargetMessage(N7_CommandExecutionState ExecState)
{
    return "Invalid target";
}

protected function string CustomErrorMessage(N7_CommandExecutionState ExecState)
{
    return "Custom Error";
}

protected function string RuntimeErrorMessage(N7_CommandExecutionState ExecState)
{
    return "Runtime Error";
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

protected final function bool ToBool(string Arg)
{
    if (IsSwitchOnValue(Arg))
    {
        return true;
    }
    else if (IsSwitchOffValue(Arg))
    {
        return false;
    }
    
    return bool(Arg);
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

protected final function bool IsSpectator(PlayerController PC)
{
    return ValidatorClass.static.IsSpectator(PC);
}

protected final function bool IsAlive(PlayerController PC)
{
    return ValidatorClass.static.IsAlive(PC);
}

protected final function bool IsAdmin(PlayerController PC)
{
    return ValidatorClass.static.IsAdmin(PC);
}

protected final function bool IsTempAdmin(PlayerController PC)
{
    return ValidatorClass.static.IsTempAdmin(PC);
}

protected final function bool IsWebAdmin(PlayerController PC)
{
    return ValidatorClass.static.IsWebAdmin(PC);
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=0
    bAdminOnly=false
    bOnlyPlayerSender=true
    bOnlyAliveSender=false
    bNotifyOnError=true
    bNotifySenderOnSuccess=true
    bNotifyTargetsOnSuccess=false
    bNotifyGlobalOnSuccess=false
    bNotifyAdminsOnlyOnSuccess=false
    bDisableNotifications=false
    bUseTargets=false
    CommandStateClass=class'N7_CommandExecutionState'
    ValidatorClass=class'N7_CommandValidator'
}
