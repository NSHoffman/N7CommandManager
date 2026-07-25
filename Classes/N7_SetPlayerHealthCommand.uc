class N7_SetPlayerHealthCommand extends N7_BinaryTargetCommand;

var protected const int MinLimit;
var protected const config int MaxLimit;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
  PC.Pawn.Health = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
  local int NewHealth;

  NewHealth = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));

  if (!IsInRange(NewHealth, MinLimit, MaxLimit))
  {
    return False;
  }

  return True;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
  return "Health can be set only during the game";
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
  return "Health must be in range from " $ MinLimit $ " to " $ MaxLimit;
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
  local string TargetName;

  TargetName = LoadTarget(ExecState);

  if (TargetName ~= "all")
  {
    return "All players' health has been set to " $ ColorizeValue(ExecState.GetArg(ECmdArgs.ARG_VALUE));
  }

  return "Your health has been set to " $ ColorizeValue(ExecState.GetArg(ECmdArgs.ARG_VALUE));
}

defaultproperties
{
  MinArgsNum=1

  MinLimit=1
  MaxLimit=500

  Aliases(0)="SH"
  Aliases(1)="SETHEALTH"
  Description="Set player's health"
  Signature="<int Health, ? (string TargetName | 'all')>"

  bOnlyAliveTargets=True

  bAdminOnly=True
}
