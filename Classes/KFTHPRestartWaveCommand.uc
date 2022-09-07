class KFTHPRestartWaveCommand extends KFTHPSetWaveCommand;

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local Array<string> RestartArgs;

    /** + 1 because KFGT.WaveNum starts from 0 */
    RestartArgs[ECmdArgs.ARG_WAVE] = ToString(KFGT.WaveNum + 1);

    ExecState.SetArgs(RestartArgs);
    Super.DoAction(ExecState);
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return "Wave restarted by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function bool CheckGameState(KFTHPCommandExecutionState ExecState)
{
    return Super.CheckGameState(ExecState) && KFGT.WaveCountDown <= 0;
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    return true;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Wave can be restarted only when it's in progress";
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=0
    Aliases=("RW")
    Signature="<>"
    Description="Restart current wave"
}
