class KFTHPSkipTradeCommand extends KFTHPTradeTimeCommand;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    KFGT.WaveCountDown = MinTradeTime;
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
