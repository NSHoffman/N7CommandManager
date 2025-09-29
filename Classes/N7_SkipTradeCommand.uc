class N7_SkipTradeCommand extends N7_TradeTimeCommand;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(KFGT.GameReplicationInfo);
    KFGRI.WaveNumber = KFGT.WaveNum;
    KFGameReplicationInfo(Level.Game.GameReplicationInfo).MaxMonstersOn = False;
    KFGT.WaveCountDown = 1;
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress') && (KFGT.bTradingDoorsOpen || KFGT.WaveNum == 0) && KFGT.WaveCountDown > 1;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Trader Time cannot be skipped when the wave is in progress";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Trader skipped by "$ColorizeSender(ExecState);
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=0

    Aliases(0)="SKIP"
    Description="Skip trader time"
    Signature="<>"
}
