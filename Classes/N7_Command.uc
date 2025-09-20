class N7_Command extends Core.Object within N7_CommandManager
    abstract
    config(N7CommandManager);

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

var protected const class<N7_CommandExecutionState> CommandStateClass;

var protected const Array<string> ArgTypes;
var protected config const Array<string> Aliases;

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
var protected const bool bDisableAdminPrivilegedAccess;

var protected config const bool bAdminOnly;
var protected config const bool bDisableColoring;
var protected config const bool bDisableNotifications;

/****************************
 *  PUBLIC INTERFACE
 ****************************/

public final function Execute(PlayerController Sender, Array<string> Args)
{
    local N7_CommandExecutionState ExecState;

    ExecState = new(self) CommandStateClass;
    ExecState.Initialize(Sender, Args, MaxArgsNum);

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
            return True;
        }
    }

    return False;
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
    return True;
}

protected function bool CheckSender(N7_CommandExecutionState ExecState)
{
	if (bOnlyPlayerSender && (!HasAdminAccess(ExecState.GetSender()) || bDisableAdminPrivilegedAccess) && IsSpectator(ExecState.GetSender()))
	{
		return False;
	}

	if (bOnlyAliveSender && (!HasAdminAccess(ExecState.GetSender()) || bDisableAdminPrivilegedAccess) && !IsAlive(ExecState.GetSender()))
	{
		return False;
	}

	return True;
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
    return HasAdminAccess(ExecState.GetSender());
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
            return False;
        }
    }

    return True;
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
                    return False;
                }
                break;

            case "word":
                if (!IsWord(CurrentArg))
                {
                    return False;
                }
                break;

            case "switch":
                if (!IsSwitchValue(CurrentArg))
                {
                    return False;
                }
                break;

            case "any":
                break;
        }
    }

    return True;
}

protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    return True;
}

protected function bool CheckTargets(N7_CommandExecutionState ExecState)
{
    return True;
}

/** Special check in case a command requires admin access under certain circumstances */
protected function bool CheckIfNonAdminExecutionAllowed(N7_CommandExecutionState ExecState)
{
    return True;
}

protected function bool CheckCustom(N7_CommandExecutionState ExecState)
{
    return True;
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
    return False;
}

/****************************
 *  COLOR HIGHLIGTHING
 ****************************/

protected final function string ColorizeMain(string Text)
{
    return Colors.ColorizeMain(Text, bDisableColoring);
}

protected final function string ColorizeSender(N7_CommandExecutionState ExecState)
{
    return Colors.ColorizeSender(
        ExecState.GetSender().PlayerReplicationInfo.PlayerName, 
        bDisableColoring
    );
}

protected final function string ColorizeTarget(string TargetName)
{
    return Colors.ColorizeTarget(TargetName, bDisableColoring);
}

protected final function string ColorizeEntity(string EntityName)
{
    return Colors.ColorizeEntity(EntityName, bDisableColoring);
}

protected final function string ColorizeValue(coerce string Value)
{
    return Colors.ColorizeValue(Value, bDisableColoring);
}

protected final function string ColorizeSignature(string Signature)
{
    return Colors.ColorizeSignature(Signature, bDisableColoring);
}

protected final function string ColorizeEmphasis(string Text)
{
    return Colors.ColorizeEmphasis(Text, bDisableColoring);
}

protected final function string ColorizeError(string Text)
{
    return Colors.ColorizeError(Text, bDisableColoring);
}

/****************************
 *  NOTIFICATIONS
 ****************************/

protected final event SendMessage(PlayerController PC, string Message)
{
    PC.TeamMessage(None, ColorizeMain(Message), 'Event');
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
    return ColorizeError("Error: ")$Message;
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
 *  HELP UTILS
 ****************************/

protected final function Help(PlayerController PC)
{
    local int i;
    local string HelpMessage;

    for (i = 0; i < Aliases.Length; i++)
    {
        HelpMessage $= Caps(Aliases[i]);

        if (i + 1 < Aliases.Length)
        {
            HelpMessage $= ", ";
        }
    }
    
    HelpMessage $= " "$ColorizeSignature(Signature)$"  ::  "$Description;
    SendMessage(PC, HelpMessage);
}

protected function ExtendedHelp(PlayerController PC);

protected function HelpSectionSeparator(PlayerController PC, string SectionTitle)
{
    SendMessage(PC, ColorizeEmphasis("========== "$Caps(SectionTitle)$" =========="));
}

/****************************
 *  ARGS COERCION UTILS
 ****************************/

protected final function bool ToBool(string Arg)
{
    if (IsSwitchOnValue(Arg))
    {
        return True;
    }
    else if (IsSwitchOffValue(Arg))
    {
        return False;
    }

    return bool(Arg);
}

/****************************
 *  VALIDATION UTILS
 ****************************/

protected final function int GetMaxAcceptableStringLength()
{
    return Validator.GetMaxAcceptableStringLength();
}

protected final function float GetStringMatchRatio(string SubStr, string SupStr)
{
  return Validator.GetStringMatchRatio(SubStr, SupStr);
}

protected final function bool IsEmptyString(string Str)
{
    return Validator.IsEmptyString(Str);
}

protected final function bool IsValidLengthString(string Str)
{
    return Validator.IsValidLengthString(Str);
}

protected final function bool IsStringPartOf(string SubStr, string SupStr)
{
    return Validator.IsStringPartOf(SubStr, SupStr);
}

protected final function bool IsLetter(string Str)
{
    return Validator.IsLetter(Str);
}

protected final function bool IsWord(string Str)
{
    return Validator.IsWord(Str);
}

protected final function bool IsSwitchOnValue(string Value)
{
    return Validator.IsSwitchOnValue(Value);
}

protected final function bool IsSwitchOffValue(string Value)
{
    return Validator.IsSwitchOffValue(Value);
}

protected final function bool IsSwitchValue(string Value)
{
    return Validator.IsSwitchValue(Value);
}

protected final function bool IsDigit(string Str)
{
    return Validator.IsDigit(Str);
}

protected final function bool IsNumber(string Str)
{
    return Validator.IsNumber(Str);
}

protected final function bool IsInRange(coerce int Number, int Start, optional int End)
{
    return Validator.IsInRange(Number, Start, End);
}

protected final function bool IsInRangeF(coerce float Number, float Start, optional float End)
{
    return Validator.IsInRangeF(Number, Start, End);
}

protected final function bool IsPlayer(Controller C)
{
    return Validator.IsPlayer(C);
}

protected final function bool IsSpectator(PlayerController PC)
{
    return Validator.IsSpectator(PC);
}

protected final function bool IsAlive(PlayerController PC)
{
    return Validator.IsAlive(PC);
}

protected final function bool IsAdmin(PlayerController PC)
{
    return Validator.IsAdmin(PC);
}

protected final function bool IsTempAdmin(PlayerController PC)
{
    return Validator.IsTempAdmin(PC);
}

protected final function bool HasAdminAccess(PlayerController PC)
{
    return Validator.HasAdminAccess(PC);
}

protected final function bool IsWebAdmin(PlayerController PC)
{
    return Validator.IsWebAdmin(PC);
}

defaultproperties
{
    CommandStateClass=class'N7CommandManager.N7_CommandExecutionState'

    MinArgsNum=0
    MaxArgsNum=0

    bNotifySenderOnSuccess=True
    bNotifyTargetsOnSuccess=False
    bNotifyGlobalOnSuccess=False
    bNotifyAdminsOnlyOnSuccess=False
    bNotifyOnError=True

    bUseTargets=False

    bOnlyPlayerSender=True
    bOnlyAliveSender=False
    bDisableAdminPrivilegedAccess=False

    bAdminOnly=False
    bDisableColoring=False
    bDisableNotifications=False
}
