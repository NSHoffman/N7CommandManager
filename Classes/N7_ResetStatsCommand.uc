class N7_ResetStatsCommand extends N7_UnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    local KFPlayerReplicationInfo KFPRI;
    KFPRI = KFPlayerReplicationInfo(PC.PlayerReplicationInfo);

    KFPRI.Deaths = 0;
    KFPRI.Kills = 0;
    KFPRI.KillAssists = 0;
    KFPRI.Score = KFGT.MinRespawnCash;
}

/** @Override */
protected function bool CheckIfNonAdminExecutionAllowed(N7_CommandExecutionState ExecState)
{
	return ExecState.GetArgC() == 0 || ExecState.GetArg(ECmdArgs.ARG_TARGETNAME) == ExecState.GetSender().PlayerReplicationInfo.PlayerName;
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Your stats have been reset";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;

    TargetName = LoadTarget(ExecState);

    if (TargetName ~= "all")
    {
        return "All players' stats have been reset";
    }

    return ColorizeTarget(TargetName)$"'s stats have been reset";
}

defaultproperties
{
    Aliases(0)="RS"
    Aliases(1)="RESETSTATS"
    Aliases(2)="RESETSCORE"
    Description="Reset Kills/Deaths/Assists/Score. Admin access allows for clearing other players score"

    Signature="<adminonly ? (string TargetName | 'all')>"
}
