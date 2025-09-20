class N7_ClearLevelCommand extends N7_GameSettingsCommand;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local Pickup P;
	local Projectile Proj;
	
	foreach DynamicActors(class'Pickup', P)
    {
        if (P != None)
        {
            P.Destroy();
        }
    }
	
	foreach DynamicActors(class'Projectile', Proj)
    {
        if (Proj != None)
        {
            Proj.Destroy();
        }
    }
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return !KFGT.IsInState('PendingMatch') && (KFGT.WaveCountDown > 0 || HasAdminAccess(ExecState.GetSender()));
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Level can be cleared only during trade time";
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    return "Level has been cleared by "$ColorizeSender(ExecState);
}

defaultproperties
{
    Aliases(0)="CL"
    Aliases(1)="CLEARLEVEL"
    Description="Clear level from pickups and projectiles"
    Signature="<>"
}
