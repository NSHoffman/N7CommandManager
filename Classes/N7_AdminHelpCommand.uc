class N7_AdminHelpCommand extends N7_HelpCommand;

/** @Override */
protected function bool ShouldDisplayHelpForCommand(N7_Command Command)
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
