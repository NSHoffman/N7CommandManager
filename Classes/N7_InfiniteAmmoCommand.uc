class N7_InfiniteAmmoCommand extends N7_BinaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
	switch (ExecState.GetArgC())
	{
		case 0:
			if (FindInfiniteAmmoPlayer(PC) == "")
			{
				AddInfiniteAmmoPlayer(PC);
			}
			else
			{
				RemoveInfiniteAmmoPlayer(PC);
			}
			break;

		case 1:
		case 2:
			if (IsSwitchOnValue(ExecState.GetArg(ECmdArgs.ARG_VALUE)))
			{
				AddInfiniteAmmoPlayer(PC);
			}
			else
			{
				RemoveInfiniteAmmoPlayer(PC);
			}
			break;
	}

	ExecState.SaveFlag(FindInfiniteAmmoPlayer(PC) != "");
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
	return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
	local string TargetName, AmmoState;

	AmmoState = ColorizeValue(ExecState.LoadEnabled());
	TargetName = LoadTarget(ExecState);

	if (TargetName ~= "all")
	{
		return "Infinite ammo is "$AmmoState$" for all players";
	}

	return "Infinite ammo is "$AmmoState;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
	local string TargetName, AmmoState;

	AmmoState = ColorizeValue(ExecState.LoadEnabled());
	TargetName = LoadTarget(ExecState);

	if (TargetName ~= "all")
	{
		return "Infinite ammo is "$AmmoState$" for all players";
	}

	return "Infinite ammo is "$AmmoState$" for "$ColorizeTarget(TargetName);
}

/** @Override */
protected function ExtendedHelp(PlayerController PC)
{
	HelpSectionSeparator(PC, "Call Options");
	SendMessage(PC, "One argument - Toggle infinite ammo for yourself");
	SendMessage(PC, "Two arguments - Toggle infinite ammo for other players");
}

defaultproperties
{
	ArgTypes(0)="switch"
	Aliases(0)="INFAMMO"
	Description="Toggle infinite ammo"
	Signature="<? (0 | 1 | ON | OFF), ? (string TargetName | 'all')>"

	bNotifyGlobalOnSuccess=True

	bAdminOnly=True
}
