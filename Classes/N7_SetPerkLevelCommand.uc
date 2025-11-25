class N7_SetPerkLevelCommand extends N7_BinaryTargetCommand;

var protected const int MinLimit;
var protected config const int MaxLimit;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    local int NewLevel;

    if (ExecState.GetArgC() > 0)
    {
        NewLevel = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));
        KFPlayerReplicationInfo(PC.PlayerReplicationInfo).ClientVeteranSkillLevel = NewLevel;
    }
    else
    {
        NewLevel = KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements).PerkHighestLevelAvailable(KFPlayerReplicationInfo(PC.PlayerReplicationInfo).ClientVeteranSkill.Default.PerkIndex);
    }

    KFPlayerReplicationInfo(PC.PlayerReplicationInfo).ClientVeteranSkillLevel = NewLevel;
    ExecState.SaveString(string(NewLevel));

    KFHumanPawn(PC.Pawn).VeterancyChanged();
    PC.SaveConfig();
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int Level;

    Level = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));

    return IsInRange(Level, MinLimit, MaxLimit);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Perk level must be in range from "$MinLimit$" to "$MaxLimit;
}

/** @Override */
protected function bool CheckIfNonAdminExecutionAllowed(N7_CommandExecutionState ExecState)
{
    return ExecState.GetArgC() <= 1 || ExecState.GetArg(ECmdArgs.ARG_TARGETNAME) == ExecState.GetSender().PlayerReplicationInfo.PlayerName;
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string SelectedLevel;

    SelectedLevel = ColorizeValue(ExecState.LoadString());

    return "Your perk level has been changed to "$SelectedLevel;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, SelectedLevel;

    TargetName = ColorizeTarget(LoadTarget(ExecState));
    SelectedLevel = ColorizeValue(ExecState.LoadString());

    return TargetName$"'s perk level has been changed to "$SelectedLevel;
}

defaultproperties
{
    MinLimit=0
    MaxLimit=6

    Aliases(0)="SPL"
    Aliases(1)="PERKLEVEL"
    Aliases(2)="SETPERKLEVEL"

    Description="Set perk level"
    Signature="<int Level, adminonly ? string TargetName>"

    bNotifyGlobalOnSuccess=True

    bAllowTargetAll=False

    bOnlyAliveTargets=True
}
