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
        NewGravity = Clamp(NewGravity, MinLimit, MaxLimit);

		PhysicsVolume.Gravity.Z = NewGravity;
	}
	else
	{
		PhysicsVolume.Gravity.Z = Level.default.DefaultGravity;
	}

    ExecState.SaveNumber(NewGravity);
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    if (ExecState.GetArgC() == 0)
    {
        return "Gravity has been reset by "$ColorizeSender(ExecState);
    }

    return "Gravity set to "$ColorizeValue(ExecState.LoadNumber())$" by "$ColorizeSender(ExecState);
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
