class N7_GravityCommand extends N7_GameSettingsCommand;

enum ECmdArgs
{
	ARG_NEWGRAVITY,
};

var protected const int MinLimit;
var protected config const int MaxLimit;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
	local int NewGravity;

	if (ExecState.GetArgC() > 0)
	{
		NewGravity = int(ExecState.GetArg(ECmdArgs.ARG_NEWGRAVITY));
		PhysicsVolume.Gravity.Z = NewGravity;
	}
	else
	{
		PhysicsVolume.Gravity.Z = Level.default.DefaultGravity;
	}
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
	local int NewGravity;

	if (ExecState.GetArgC() > 0)
	{
		NewGravity = int(ExecState.GetArg(ECmdArgs.ARG_NEWGRAVITY));

		if (!IsInRange(NewGravity, MinLimit, MaxLimit))
		{
			return False;
		}
	}
 
	return True;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local int NewGravity;

    NewGravity = PhysicsVolume.Gravity.Z;

    if (ExecState.GetArgC() == 0)
    {
        return "Gravity has been reset by "$ColorizeSender(ExecState);
    }

    return "Gravity set to "$ColorizeValue(NewGravity)$" by "$ColorizeSender(ExecState);
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
	return "New Gravity must be in range from "$MinLimit$" to "$MaxLimit;
}

defaultproperties
{
	MaxArgsNum=1
	ArgTypes(0)="number"

	MinLimit=-2000
	MaxLimit=-50

	Aliases(0)="GR"
	Aliases(1)="GRAVITY"
	Description="Set gravity"
	Signature="<? int Gravity>"

	bAdminOnly=True
}
