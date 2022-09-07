class KFTHPSkipTradeCommand extends KFTHPTradeTimeCommand;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local KFGameReplicationInfo KFGRI;

    KFGRI = KFGameReplicationInfo(KFGT.GameReplicationInfo);
    KFGRI.WaveNumber = KFGT.WaveNum;
    KFGT.WaveCountDown = 1;
}

/** @Override */
protected function bool CheckGameState(KFTHPCommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress') 
        && (KFGT.bTradingDoorsOpen || KFGT.WaveNum == 0)
        && KFGT.WaveCountDown > 5;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Trader Time cannot be skipped when the wave is in progress";
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "Trader skipped by "$GetInstigatorName(ExecState);
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=0
    Aliases(0)="SKIP"
    Signature="<>"
    Description="Skip trader time"
}
