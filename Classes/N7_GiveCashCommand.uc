class N7_GiveCashCommand extends N7_BinaryTargetCommand;

var protected const int MinCashAmount; 
var protected globalconfig const int MaxCashAmount;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    local int CashAmount;
    CashAmount = ToInt(ExecState.GetArg(ECmdArgs.ARG_VALUE));

    if (!IsInRange(CashAmount, MinCashAmount, MaxCashAmount) && IsInRange(CashAmount, MinCashAmount))
    {
        CashAmount = MaxCashAmount;
    }
    else if (!IsInRange(CashAmount, MinCashAmount))
    {
        CashAmount = MinCashAmount;
    }
    PC.PlayerReplicationInfo.Score += CashAmount;
    ExecState.SaveNumber(CashAmount);
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, CashAmount;

    TargetName = LoadTarget(ExecState);
    CashAmount = ColorizeValue(ExecState.LoadNumber());

    if (TargetName ~= "all")
    {
        return "All players have been given "$CashAmount$" of dosh";
    }

    return "You have been given "$CashAmount$" of dosh";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, CashAmount;

    TargetName = LoadTarget(ExecState);
    CashAmount = ColorizeValue(ExecState.LoadNumber());

    if (TargetName ~= "all")
    {
        return "All players have been given "$CashAmount$" of dosh";
    }

    return ColorizeTarget(TargetName)$" has been given "$CashAmount$" of dosh";
}

defaultproperties
{
    bAdminOnly=true
    MinArgsNum=1
    Aliases(0)="GC"
    Aliases(1)="GD"
    Aliases(2)="CASH"
    Aliases(3)="DOSH"
    Signature="<int Amount, ? (string TargetName | 'all')>"
    Description="Give Money"
    MinCashAmount=1
    MaxCashAmount=50000
    bNotifyGlobalOnSuccess=true
}
