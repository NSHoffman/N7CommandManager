class N7_RestartWaveCommand extends N7_GameSettingsCommand;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    GSU.SetWave(KFGT.WaveNum + 1);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return (KFGT.IsInState('MatchInProgress') || KFGT.bGameEnded && KFGameReplicationInfo(Level.Game.GameReplicationInfo).EndGameType == 1) && KFGT.WaveCountDown <= 0;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Wave restarted by "$ColorizeSender(ExecState);
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

    Aliases(0)="RW"
    Description="Restart current wave"
    Signature="<>"
}
