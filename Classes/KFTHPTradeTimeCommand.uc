class KFTHPTradeTimeCommand extends KFTHPGameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWTIME,
};

var protected const int MinTradeTime;
var protected const int MaxTradeTime;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local int NewTradeTime;

    NewTradeTime = ToInt(ExecState.GetArg(ECmdArgs.ARG_NEWTIME));

    if (IsInRange(NewTradeTime, MinTradeTime, MaxTradeTime))
    {
        KFGT.WaveCountDown = NewTradeTime; 
    }
    else if (IsInRange(NewTradeTime, MinTradeTime))
    {
        KFGT.WaveCountDown = MaxTradeTime;
    }
    else
    {
        KFGT.WaveCountDown = MinTradeTime;
    }
}

/** @Override */
protected function bool CheckCustom(KFTHPCommandExecutionState ExecState)
{
    if (!KFGT.bTradingDoorsOpen)
    {
        return false;
    }

    return true;
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "Trade Time set to "$KFGT.WaveCountDown$"s by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function string CustomErrorMessage(KFTHPCommandExecutionState ExecState)
{
    return "Trader Time cannot be set during the wave";
}

defaultproperties
{
    MinArgsNum=1
    MaxArgsNum=1
    MinTradeTime=6
    MaxTradeTime=600
    Aliases(0)="TT"
    Aliases(1)="TRADE"
    Aliases(2)="SETTRADE"
    ArgTypes(0)="number"
    Signature="<int TradeTime>"
    Description="Set trader time in seconds"
}
