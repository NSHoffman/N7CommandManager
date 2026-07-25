class N7_RestorePlayerAmmoCommand extends N7_UnaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
  GSU.RestorePlayerAmmo(PC);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string InvalidGameStateMessage()
{
  return "Ammo can be restored only during the game";
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
  local string TargetName;

  TargetName = LoadTarget(ExecState);

  if (TargetName ~= "all")
  {
    return "All players' ammo has been restored";
  }

  return "Your ammo has been restored";
}

defaultproperties
{
  Aliases(0)="RAMMO"
  Aliases(1)="RESTOREAMMO"
  Description="Restore player's ammo"

  bOnlyAliveTargets=True

  bAdminOnly=True
}
