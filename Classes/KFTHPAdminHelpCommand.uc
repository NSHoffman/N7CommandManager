class KFTHPAdminHelpCommand extends KFTHPHelpCommand;

/** @Override */
protected function bool ShouldDisplayHelpForCommand(KFTHPCommand Command)
{
    return Command.IsAdminOnly();
}

defaultproperties
{
    bAdminOnly=true
    Aliases(0)="AHELP"
    Aliases(1)="ADMINHELP"
    Description="Show a list of commands available to admins only or display info about one specific command"
}
