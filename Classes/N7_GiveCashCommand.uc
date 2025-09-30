class N7_GiveCashCommand extends N7_BinaryTargetCommand;

var protected const int MinLimit; 
var protected config const int MaxLimit;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    local int CashAmount;

    CashAmount = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));
    CashAmount = Clamp(CashAmount, MinLimit, MaxLimit);

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
        return "All players have been doshed up by "$CashAmount$" pounds";
    }

    return "You have been doshed up by "$CashAmount$" pounds";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, CashAmount;

    TargetName = LoadTarget(ExecState);
    CashAmount = ColorizeValue(ExecState.LoadNumber());

    if (TargetName ~= "all")
    {
        return "All players have been doshed up by "$CashAmount$" pounds";
    }

    return ColorizeTarget(TargetName)$" has been doshed up by "$CashAmount$" pounds";
}

defaultproperties
{
    MinArgsNum=1

    MinLimit=1
    MaxLimit=50000

    Aliases(0)="GC"
    Aliases(1)="GD"
    Aliases(2)="CASH"
    Aliases(3)="DOSH"
    Description="Give money to the player"
    Signature="<int Amount, ? (string TargetName | 'all')>"

    bNotifyGlobalOnSuccess=True

    bAdminOnly=True
}
