class N7_BanCommand extends N7_UnaryTargetCommand;

enum ECmdArgs_X
{
    ARG_TARGETNAME,
    ARG_PERMANENT,
};

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    local string IP;
    local bool bPermanentBan;
    local AccessControl AC;

    IP = PC.GetPlayerNetworkAddress();
    IP = Left(IP, InStr(IP, ":"));

    bPermanentBan = ToBool(ExecState.GetArg(ECmdArgs_X.ARG_PERMANENT));
    AC = KFGT.AccessControl;

    if (bPermanentBan)
    {
        if (AC.bBanByID)
        {
            AC.BannedIDs[AC.BannedIDs.Length] = PC.GetPlayerIDHash()@PC.PlayerReplicationInfo.PlayerName;
        }
        else
        {
            AC.IPPolicies[AC.IPPolicies.Length] = "DENY;"$IP;
        }

        AC.SaveConfig();
        PC.ClientNetworkMessage("AC_Ban", KFGT.GameReplicationInfo.AdminEmail);
    }
    else
    {
        if (AC.bBanByID)
        {
            AC.SessionBannedIDs[AC.SessionBannedIDs.Length] = PC.GetPlayerIDHash()@PC.PlayerReplicationInfo.PlayerName;
        }
        else
        {
            AC.SessionIPPolicies[AC.SessionIPPolicies.Length] = "DENY;"$IP;
        }

        AC.SaveConfig();
        PC.ClientNetworkMessage("AC_SessionBan", KFGT.GameReplicationInfo.AdminEmail);
    }

    if (PC.Pawn != None && Vehicle(PC.Pawn) == None)
    {
        PC.Pawn.Destroy();
    }
    PC.Destroy();
}

/** @Override */
protected function bool CheckTargetCustom(N7_CommandExecutionState ExecState, PlayerController Target)
{
    return NetConnection(Target.Player) != None && KFGT.AccessControl.CheckIPPolicy(Target.GetPlayerNetworkAddress()) == 0;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;
    local string BanSuccessMessage;

    TargetName = ColorizeTarget(LoadTarget(ExecState));
    BanSuccessMessage = TargetName$" was banned";

    if (ToBool(ExecState.GetArg(ECmdArgs_X.ARG_PERMANENT)))
    {
        BanSuccessMessage $= " permanently"; 
    }

    return BanSuccessMessage;
}

defaultproperties
{
    MinArgsNum=1
    MaxArgsNum=2
    ArgTypes(1)="switch"

    Aliases(0)="BAN"
    Description="Ban player for the time of current session or permanently"
    Signature="<string TargetName, ? (0 | 1 | ON | OFF) IsPermanent>"

    bNotifyTargetsOnSuccess=False
    bNotifyGlobalOnSuccess=True

    bAllowTargetAll=False
    bOnlyPlayerTargets=False
    bOnlyNonAdminTargets=True
    bAdminOnly=True
}
