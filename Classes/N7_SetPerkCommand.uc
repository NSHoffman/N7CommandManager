class N7_SetPerkCommand extends N7_BinaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    local class<KFVeterancyTypes> SelectedPerkClass;
    local int PerkIndex;

    PerkIndex = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));
    SelectedPerkClass = KFGT.default.LoadedSkills[PerkIndex];

    ExecState.SaveString(SelectedPerkClass.default.VeterancyName);

    KFPlayerController(PC).default.SelectedVeterancy = SelectedPerkClass;
    KFPlayerController(PC).SetSelectedVeterancy(SelectedPerkClass);

    KFPlayerReplicationInfo(PC.PlayerReplicationInfo).ClientVeteranSkill = SelectedPerkClass;
    KFPlayerReplicationInfo(PC.PlayerReplicationInfo).ClientVeteranSkillLevel = KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements).PerkHighestLevelAvailable(SelectedPerkClass.default.PerkIndex);

    KFHumanPawn(PC.Pawn).VeterancyChanged();
    PC.SaveConfig();
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local int PerkIndex;
    PerkIndex = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));

    return IsInRange(PerkIndex, 0, KFGT.default.LoadedSkills.Length - 1);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    local string PerkIndex;
    PerkIndex = ColorizeValue(ExecState.GetArg(ECmdArgs.ARG_VALUE));

    return "Cannot find perk with index "$PerkIndex;
}

/** @Override */
protected function bool CheckIfNonAdminExecutionAllowed(N7_CommandExecutionState ExecState)
{
    return ExecState.GetArgC() == 1 || ExecState.GetArg(ECmdArgs.ARG_TARGETNAME) == ExecState.GetSender().PlayerReplicationInfo.PlayerName;
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string SelectedPerk;

    SelectedPerk = ColorizeValue(ExecState.LoadString());

    return "Your perk has been changed to "$SelectedPerk;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, SelectedPerk;
    
    TargetName = ColorizeTarget(LoadTarget(ExecState));
    SelectedPerk = ColorizeValue(ExecState.LoadString());

    return TargetName$"'s perk has been changed to "$SelectedPerk;
}

/** @Override */
protected function ExtendedHelp(PlayerController PC)
{
    local int i;
    local class<KFVeterancyTypes> CurrentPerk;

    HelpSectionSeparator(PC, "Available Perks");

    for (i = 0; i < KFGT.default.LoadedSkills.Length; i++)
    {
        CurrentPerk = KFGT.default.LoadedSkills[i];
        SendMessage(PC, CurrentPerk.default.PerkIndex$" - "$CurrentPerk.default.VeterancyName);
    }
}

defaultproperties
{
    MinArgsNum=1

    Aliases(0)="SP"
    Aliases(1)="PERK"
    Aliases(2)="SETPERK"
    Description="Set perk. Admin access allows for changing other players perks"
    Signature="<int PerkIndex, adminonly ? string TargetName>"

    bNotifyGlobalOnSuccess=True

    bAllowTargetAll=False
}
