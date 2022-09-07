class KFTHPTempAdminCommand extends KFTHPUnaryTargetCommand;

enum ECmdArgs_X
{
    ARG_TARGETNAME,
    ARG_FLAG,
};

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    local bool bGrantTempAdmin;
    bGrantTempAdmin = ToBool(ExecState.GetArg(ECmdArgs_X.ARG_FLAG));

    if (bGrantTempAdmin)
    {
        PC.MakeAdmin();
        /** 
         * Setting both bAdmin and bSilentAdmin 
         * Is a hack which allows to tell temp admin access
         */
        PC.PlayerReplicationInfo.bAdmin = true;
        PC.PlayerReplicationInfo.bSilentAdmin = true;
        PC.AddCheats();
    }
    else
    {
        PC.AdminLogout();
    }
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName, AdminAccessGrantStatus;
    local bool bGrantTempAdmin;

    TargetName = LoadTarget(ExecState);
    bGrantTempAdmin = ToBool(ExecState.GetArg(ECmdArgs_X.ARG_FLAG));

    if (bGrantTempAdmin)
        AdminAccessGrantStatus = "granted to";
    else
        AdminAccessGrantStatus = "revoked from";

    return "Temporary admin access has been "$AdminAccessGrantStatus$" you";
}

/** @Override */
protected function string GetGlobalSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    local string TargetName, AdminAccessGrantStatus;
    local bool bGrantTempAdmin;

    TargetName = LoadTarget(ExecState);
    bGrantTempAdmin = ToBool(ExecState.GetArg(ECmdArgs_X.ARG_FLAG));

    if (bGrantTempAdmin)
        AdminAccessGrantStatus = "granted to";
    else
        AdminAccessGrantStatus = "revoked from";

    if (TargetName ~= "all")
    {
        return "Temporary admin access has been "$AdminAccessGrantStatus$" all players";
    }

    return "Temporary admin access has been "$AdminAccessGrantStatus$" "$TargetName;
}

defaultproperties
{
    bAdminOnly=true
    MinArgsNum=2
    MaxArgsNum=2
    ArgTypes(1)="switch"
    Aliases(0)="TEMPADMIN"
    Description="Grant temporary admin access to players"
    Signature="<string TargetName, (0 | 1 | ON | OFF)>"
    bAllowTargetSelf=false
    bOnlyPlayerTargets=false
    bOnlyNonAdminTargets=true
    bNotifyGlobalOnSuccess=true
}