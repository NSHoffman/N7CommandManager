class N7_RestartWaveCommand extends N7_SetWaveCommand;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local Array<string> RestartArgs;

    /** + 1 because KFGT.WaveNum starts from 0 */
    RestartArgs[ECmdArgs.ARG_WAVE] = ToString(KFGT.WaveNum + 1);

    ExecState.SetArgs(RestartArgs);
    Super.DoAction(ExecState);
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Wave restarted by "$GetInstigatorName(ExecState);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return Super.CheckGameState(ExecState) && KFGT.WaveCountDown <= 0;
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
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
