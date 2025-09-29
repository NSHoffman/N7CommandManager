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
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(KFGT.GameReplicationInfo);

    NewTradeTime = int(ExecState.GetArg(ECmdArgs.ARG_NEWTIME));
    KFGT.WaveCountDown = FClamp(NewTradeTime, MinLimit, MaxLimit);

    if (KFGT.WaveCountDown <= 5)
    {
        KFGRI.WaveNumber = KFGT.WaveNum;
        KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonstersOn = False;
    }
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress') && (KFGT.bTradingDoorsOpen || KFGT.WaveNum == 0 && KFGT.WaveCountDown > 0);
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
    MinArgsNum=1
    MaxArgsNum=1
    ArgTypes(0)="number"

    MinLimit=1
    MaxLimit=3600

    Aliases(0)="TT"
    Aliases(1)="TRADE"
    Aliases(2)="SETTRADE"
    Description="Set trader time in seconds"
    Signature="<int TradeTime>"
}
