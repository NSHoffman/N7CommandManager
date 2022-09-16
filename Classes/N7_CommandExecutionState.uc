class N7_CommandExecutionState extends Core.Object within N7_Command;

enum ECommandStatus
{
    CS_NONE,
    CS_INITIALIZED,
    CS_VALIDATING,
    CS_PROCESSING,
    CS_FAILURE,
    CS_SUCCESS,
};

/** Execution State */
var protected ECommandStatus Status;
var protected bool bStopTargetSearch;

var protected PlayerController Sender;
var protected Array<PlayerController> Targets;
var protected Array<string> Args;
var protected Array<string> InitialArgs;

var protected int ErrNo;

/** Preserved State */
var protected string PreservedString;
var protected string PreservedTarget;

var protected int PreservedNumber;
var protected int PreservedMinLimit;
var protected int PreservedMaxLimit;

var protected float PreservedNumberF;
var protected float PreservedMinLimitF;
var protected float PreservedMaxLimitF;

var protected bool bPreservedFlag;

/****************************
 *  STATE ACCESSORS
 ****************************/

public final function PlayerController GetSender()
{
    return Sender;
}

public final function Array<string> GetArgs()
{
    return Args;
}

public final function string GetArg(int i)
{
    if (i < Args.Length)
    {
        return Args[i];
    }

    return "";
}

public final function int GetArgC()
{
    return Args.Length;
}

public final function Array<PlayerController> GetTargets()
{
    return Targets;
}

public final function PlayerController GetTarget(int i)
{
    if (i < Targets.Length)
    {
        return Targets[i];
    }

    return None;
}

public final function int GetTargetsNum()
{
    return Targets.Length;
}

public final function int GetErrNo()
{
    return ErrNo;
}

public final function bool ShouldStopTargetSearch()
{
    return bStopTargetSearch;
}

/****************************
 *  STATE INITIALIZATION
 ****************************/

public final function Initialize(
    PlayerController InitSender, Array<string> InitArgs)
{
    local int i;

    for (i = 1; i < InitArgs.Length; i++)
    {
        if (Len(InitArgs[i]) > 0)
        {
            Args[Args.Length] = InitArgs[i];
            InitialArgs[InitialArgs.Length] = InitArgs[i];
        }
    }

    Sender = InitSender;
    ErrNo = ERRNO_NONE;
    bStopTargetSearch = false;

    SetInitializedStatus();
}

/****************************
 *  ARGS MANAGEMENT
 ****************************/

public final function SetArgs(Array<string> NewArgs)
{
    Args = NewArgs;
}

public final function RestoreArgs()
{
    Args = InitialArgs;
}

/****************************
 *  TARGET MANAGEMENT
 ****************************/

public final function AddTarget(PlayerController Target)
{
    Targets[Targets.Length] = Target;
}

public final function bool IsTarget(PlayerController PC)
{
    local int i;

    for (i = 0; i < Targets.Length; i++)
    {
        if (Targets[i] == PC)
        {
            return true;
        }
    }

    return false;
}

public final function StopTargetSearch()
{
    bStopTargetSearch = true;
}

/****************************
 *  STATUS TRANSITIONING
 ****************************/

public final function SetInitializedStatus()
{
    UpdateCommandStatus(CS_INITIALIZED);
}

public final function SetValidatingStatus()
{
    UpdateCommandStatus(CS_VALIDATING);
}

public final function SetProcessingStatus()
{
    UpdateCommandStatus(CS_PROCESSING);
}

public final function SetSuccessStatus()
{
    UpdateCommandStatus(CS_SUCCESS);
}

public final function SetErrorNoGameType()
{
    SetErrorStatus(ERRNO_NOGAMETYPE);
}

public final function SetErrorGameState()
{
    SetErrorStatus(ERRNO_GAMESTATE);
}

public final function SetErrorSender()
{
    SetErrorStatus(ERRNO_SENDER);
}

public final function SetErrorNotAdmin()
{
    SetErrorStatus(ERRNO_NOTADMIN);
}

public final function SetErrorArgC()
{
    SetErrorStatus(ERRNO_ARGC);
}

public final function SetErrorArgL()
{
    SetErrorStatus(ERRNO_ARGL);
}

public final function SetErrorArgT()
{
    SetErrorStatus(ERRNO_ARGT);
}

public final function SetErrorInvalArgs()
{
    SetErrorStatus(ERRNO_INVALARGS);
}

public final function SetErrorInvalTarget()
{
    SetErrorStatus(ERRNO_INVALTARGET);
}

public final function SetErrorCustom()
{
    SetErrorStatus(ERRNO_CUSTOM);
}

public final function SetErrorRuntime()
{
    SetErrorStatus(ERRNO_RUNTIME);
}

protected final function SetErrorStatus(int NextErrNo)
{
    UpdateCommandStatus(CS_FAILURE, NextErrNo);
}

protected final function UpdateCommandStatus(ECommandStatus NextStatus, optional int NextErrNo)
{
    Status = NextStatus;

    if (IsFailed())
    {
        ErrNo = NextErrNo;
    }
    else
    {
        ErrNo = ERRNO_NONE;
    }
}

/****************************
 *  STATUS CHECK
 ****************************/

public final function bool IsInitialized()
{
    return Status == CS_INITIALIZED;
}

public final function bool IsValidating()
{
    return Status == CS_VALIDATING;
}

public final function bool IsProcessing()
{
    return Status == CS_PROCESSING;
}

public final function bool IsSuccess()
{
    return Status == CS_SUCCESS;
}

public final function bool IsFailed()
{
    return Status == CS_FAILURE;
}

/****************************
 *  PRESERVED API
 ****************************/

public final function SaveString(string Value)
{
    PreservedString = Value;
}

public final function SaveTarget(string Value)
{
    PreservedTarget = Value;
}

public final function SaveNumber(int Value)
{
    PreservedNumber = Value;
}

public final function SaveMinLimit(int Value)
{
    PreservedMinLimit = Value;
}

public final function SaveMaxLimit(int Value)
{
    PreservedMaxLimit = Value;
}

public final function SaveNumberF(float Value)
{
    PreservedNumberF = Value;
}

public final function SaveMinLimitF(float Value)
{
    PreservedMinLimitF = Value;
}

public final function SaveMaxLimitF(float Value)
{
    PreservedMaxLimitF = Value;
}

public final function SaveFlag(bool bValue)
{
    bPreservedFlag = bValue;
}

public final function string LoadString()
{
    return PreservedString;
}

public final function string LoadTarget()
{
    return PreservedTarget;
}

public final function int LoadNumber()
{
    return PreservedNumber;
}

public final function int LoadMinLimit()
{
    return PreservedMinLimit;
}

public final function int LoadMaxLimit()
{
    return PreservedMaxLimit;
}

public final function float LoadNumberF()
{
    return PreservedNumberF;
}

public final function float LoadMinLimitF()
{
    return PreservedMinLimitF;
}

public final function float LoadMaxLimitF()
{
    return PreservedMaxLimitF;
}

public final function bool LoadFlag()
{
    return bPreservedFlag;
}

public final function string LoadSwitch(optional bool bAllCaps)
{
    if (bPreservedFlag)
    {
        return EnsureUpperCase("On", bAllCaps);
    }
    
    return EnsureUpperCase("Off", bAllCaps);
}

public final function string LoadEnabled(optional bool bAllCaps)
{
    if (bPreservedFlag)
    {
        return EnsureUpperCase("enabled", bAllCaps);
    }
    
    return EnsureUpperCase("disabled", bAllCaps);
}

protected final function string EnsureUpperCase(string Value, bool bAllCaps)
{
    if (bAllCaps)
    {
        return Caps(Value);
    }

    return Value;
}

defaultproperties
{}
