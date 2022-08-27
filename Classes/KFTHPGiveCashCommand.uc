class KFTHPGiveCashCommand extends KFTHPBinaryTargetCommand;

var protected const int MinCashAmount; 
var protected const int MaxCashAmount;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    PC.PlayerReplicationInfo.Score += KFTHPCommandPreservingState(ExecState).LoadNumber();
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local int CashAmount;
    CashAmount = ToInt(ExecState.GetArg(ECmdArgs.ARG_VALUE));

    if (!IsInRange(CashAmount, MinCashAmount, MaxCashAmount))
    {
        return false; 
    }

    KFTHPCommandPreservingState(ExecState).SaveNumber(CashAmount);

    return true;
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "Cash Amount must be positive number from "$MinCashAmount$" to "$MaxCashAmount;
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    local int CashAmount;

    TargetName = LoadTarget(ExecState);
    CashAmount = KFTHPCommandPreservingState(ExecState).LoadNumber();

    if (TargetName ~= "all")
    {
        return "All players have been given "$CashAmount$" of dosh";
    }

    return "You have been given "$CashAmount$" of dosh";
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    local int CashAmount;

    TargetName = LoadTarget(ExecState);
    CashAmount = KFTHPCommandPreservingState(ExecState).LoadNumber();

    if (TargetName ~= "all")
    {
        return "All players have been given "$CashAmount$" of dosh";
    }

    return TargetName$" has been given "$CashAmount$" of dosh";
}

defaultproperties
{
    bAdminOnly=true
    Aliases(0)="GC"
    Aliases(1)="GD"
    Aliases(2)="CASH"
    Aliases(3)="DOSH"
    Signature="<int Amount, optional (string TargetName | 'all')>"
    Description="Give Money"
    MinCashAmount=1
    MaxCashAmount=50000
    bNotifyGlobalOnSuccess=true
}
