class N7_RestartWaveCommand extends N7_SetWaveCommand;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local Array<string> RestartArgs;

    /** + 1 because KFGT.WaveNum starts from 0 */
    RestartArgs[ECmdArgs.ARG_WAVE] = string(KFGT.WaveNum + 1);

    ExecState.SetArgs(RestartArgs);
    super.DoAction(ExecState);
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Wave restarted by "$ColorizeSender(ExecState);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return super.CheckGameState(ExecState) && KFGT.WaveCountDown <= 0;
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    return True;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Wave can be restarted only when it's in progress";
}

defaultproperties
{
    Aliases(0)="RW"
    MinArgsNum=0
    MaxArgsNum=0
    Signature="<>"
    Description="Restart current wave"
}
