class N7_SetPlayerArmorCommand extends N7_BinaryTargetCommand;

var protected const int MinLimit;
var protected const config int MaxLimit;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
  PC.Pawn.ShieldStrength = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
  local int NewArmor;

  NewArmor = int(ExecState.GetArg(ECmdArgs.ARG_VALUE));

  if (!IsInRange(NewArmor, MinLimit, MaxLimit))
  {
    return False;
  }

  return True;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
  return "Armor can be set only during the game";
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
  return "Armor must be in range from " $ MinLimit $ " to " $ MaxLimit;
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
  local string TargetName;

  TargetName = LoadTarget(ExecState);

  if (TargetName ~= "all")
  {
    return "All players' armor has been set to " $ ColorizeValue(ExecState.GetArg(ECmdArgs.ARG_VALUE));
  }

  return "Your armor has been set to " $ ColorizeValue(ExecState.GetArg(ECmdArgs.ARG_VALUE));
}

defaultproperties
{
  MinArgsNum=1

  MinLimit=0
  MaxLimit=100

  Aliases(0)="SAR"
  Aliases(1)="SETARMOR"
  Description="Set player's armor"
  Signature="<int Armor, ? (string TargetName | 'all')>"

  bOnlyAliveTargets=True

  bAdminOnly=True
}
