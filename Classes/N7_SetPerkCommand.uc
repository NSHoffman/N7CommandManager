class N7_SetPerkCommand extends N7_BinaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    local class<KFVeterancyTypes> SelectedPerkClass;
    local string SelectedPerk;
    local int i;

    SelectedPerk = ExecState.LoadString();

    for (i = 0; i < KFGT.LoadedSkills.Length; i++)
    {
        if (IsStringPartOf(SelectedPerk, KFGT.LoadedSkills[i].default.VeterancyName))
        {
            SelectedPerkClass = KFGT.LoadedSkills[i];
        }
    }

    KFPlayerController(PC).SetSelectedVeterancy(SelectedPerkClass);
    KFPlayerReplicationInfo(PC.PlayerReplicationInfo).ClientVeteranSkill = SelectedPerkClass;
    KFPlayerReplicationInfo(PC.PlayerReplicationInfo).ClientVeteranSkillLevel = 
        KFSteamStatsAndAchievements(PC.SteamStatsAndAchievements).PerkHighestLevelAvailable(SelectedPerkClass.default.PerkIndex);

    KFHumanPawn(PC.Pawn).VeterancyChanged();
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local string SelectedPerk;
    local int i;

    SelectedPerk = ExecState.GetArg(ECmdArgs.ARG_VALUE);

    for (i = 0; i < KFGT.LoadedSkills.Length; i++)
    {
        if (IsStringPartOf(SelectedPerk, KFGT.LoadedSkills[i].default.VeterancyName))
        {
            ExecState.SaveString(KFGT.LoadedSkills[i].default.VeterancyName);
            return true;
        }
    }

    return false;
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    local string InvalidPerk;
    InvalidPerk = ColorizeValue(ExecState.GetArg(ECmdArgs.ARG_VALUE));

    return "Cannot find perk "$InvalidPerk;
}

/** @Override */
protected function bool CheckIfNonAdminExecutionAllowed(N7_CommandExecutionState ExecState)
{
    return ExecState.GetArgC() == 1 
        || IsStringPartOf(ExecState.GetArg(ECmdArgs.ARG_TARGETNAME), ExecState.GetSender().PlayerReplicationInfo.PlayerName);
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

defaultproperties
{
    MinArgsNum=1
    ArgTypes(0)="any"
    Aliases(0)="SP"
    Aliases(1)="PERK"
    Aliases(2)="SETPERK"
    Signature="<string Perk, adminonly ? string TargetName>"
    Description="Set Perk. Admin access allows for changing other players perks"
    bAllowTargetAll=false
    bNotifyGlobalOnSuccess=true
}