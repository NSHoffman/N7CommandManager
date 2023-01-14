class N7_TempAdminCommand extends N7_UnaryTargetCommand;

enum ECmdArgs_X
{
    ARG_TARGETNAME,
    ARG_FLAG,
};

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
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
        PC.PlayerReplicationInfo.bAdmin = True;
        PC.PlayerReplicationInfo.bSilentAdmin = True;
        PC.AddCheats();
    }
    else
    {
        PC.AdminLogout();
    }
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
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
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
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

    return "Temporary admin access has been "$AdminAccessGrantStatus$" "$ColorizeTarget(TargetName);
}

defaultproperties
{
    bAdminOnly=True
    MinArgsNum=2
    MaxArgsNum=2
    ArgTypes(1)="switch"
    Aliases(0)="TEMPADMIN"
    Description="Grant temporary admin access to players"
    Signature="<string TargetName, (0 | 1 | ON | OFF)>"
    bAllowTargetSelf=False
    bOnlyPlayerTargets=False
    bOnlyNonAdminTargets=True
    bNotifyGlobalOnSuccess=True
}
