class KFTHPBanCommand extends KFTHPUnaryTargetCommand;

const ARG_PERMANENT = 1;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    local string IP;
    local bool bPermanentBan;
    local AccessControl AC;

    IP = PC.GetPlayerNetworkAddress();
    IP = Left(IP, InStr(IP, ":"));

    bPermanentBan = ToBool(ExecState.GetArg(ARG_PERMANENT));
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
protected function bool CheckTargetCustom(
    KFTHPCommandExecutionState ExecState, PlayerController Target)
{
    return NetConnection(Target.Player) != None && KFGT.AccessControl.CheckIPPolicy(Target.GetPlayerNetworkAddress()) == 0;
}

/** @Override */
protected function string InvalidTargetMessage(KFTHPCommandExecutionState ExecState)
{
    return "Cannot find valid targets with name "$LoadTarget(ExecState);
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName;
    local string BanSuccessMessage;

    TargetName = LoadTarget(ExecState);
    BanSuccessMessage = TargetName$" was banned";

    if (ToBool(ExecState.GetArg(ARG_PERMANENT)))
    {
        BanSuccessMessage $= " permanently"; 
    }

    return BanSuccessMessage;
}

defaultproperties
{
    bAdminOnly=true
    MinArgsNum=1
    MaxArgsNum=2
    ArgTypes(1)="switch"
    Aliases(0)="BAN"
    Description="Ban Player"
    Signature="<string TargetName, ? (0 | 1 | ON | OFF) IsPermanent>"
    bAllowTargetAll=false
    bNotifyTargetsOnSuccess=false
    bNotifyGlobalOnSuccess=true
}
