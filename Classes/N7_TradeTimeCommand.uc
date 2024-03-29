class N7_TradeTimeCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
    ARG_NEWTIME,
};

var protected const int MinLimit;
var protected config const int MaxLimit;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local int NewTradeTime;

    NewTradeTime = int(ExecState.GetArg(ECmdArgs.ARG_NEWTIME));
    KFGT.WaveCountDown = FClamp(NewTradeTime, MinLimit, MaxLimit);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress') 
        && (KFGT.bTradingDoorsOpen || KFGT.WaveNum == 0 && KFGT.WaveCountDown > 0);
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Trade Time set to "$ColorizeValue(KFGT.WaveCountDown)$"s by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Trader Time cannot be set during the wave";
}

defaultproperties
{
    Aliases(0)="TT"
    Aliases(1)="TRADE"
    Aliases(2)="SETTRADE"
    MinLimit=6
    MaxLimit=3600
    MinArgsNum=1
    MaxArgsNum=1
    ArgTypes(0)="number"
    Signature="<int TradeTime>"
    Description="Set trader time in seconds"
}
