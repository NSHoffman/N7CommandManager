class KFTHPSkipTradeCommand extends KFTHPTradeTimeCommand;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    KFGT.WaveCountDown = MinTradeTime;
}

/** @Override */
protected function bool CheckGameState(KFTHPCommandExecutionState ExecState)
{
    if (KFGT.IsInState('MatchInProgress') && (KFGT.bTradingDoorsOpen || KFGT.WaveNum == 0) && KFGT.WaveCountDown > 5)
    {
        return true;
    }

    return false;
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
