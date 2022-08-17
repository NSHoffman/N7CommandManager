class KFTHPHelpCommand extends KFTHPCommand;

enum ECmdArgs
{
    ARG_COMMAND,
};

/** @Override */
protected function DoAction(KFTHPCommandExecutionState ExecState)
{
    local string CommandString;
    local KFTHPCommand RequestedCommand;
    local int i;

    switch (ExecState.GetArgC())
    {
        case 0:
            for (i = 0; i < Commands.Length; i++)
            {
                if (Commands[i] != None && ShouldDisplayHelpForCommand(Commands[i]))
                {
                    DisplayHelpForCommand(ExecState.GetSender(), Commands[i]);
                }
            }
            break;

        case 1:
            CommandString = ExecState.GetArg(ECmdArgs.ARG_COMMAND);
            RequestedCommand = GetCommand(CommandString);

            DisplayHelpForCommand(ExecState.GetSender(), RequestedCommand);
            break;
    }
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local string CommandString;

    if (ExecState.GetArgC() == 1)
    {
        CommandString = ExecState.GetArg(ECmdArgs.ARG_COMMAND);
        return GetCommand(CommandString) != None;
    }

    return true;
}

protected final function DisplayHelpForCommand(PlayerController Target, KFTHPCommand Command)
{
    SendMessage(Target, Command.GetHelpString());
}

protected function bool ShouldDisplayHelpForCommand(KFTHPCommand Command)
{
    return !Command.IsAdminOnly();
}

protected function KFTHPCommand GetCommand(string CommandString)
{
    local int i;

    for (i = 0; i < Commands.Length; i++)
    {
        if (Commands[i] != None && Commands[i].HasAlias(Caps(CommandString)))
        {
            return Commands[i];
        }
    }

    return None;
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "Unrecognized command";
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="HELP"
    ArgTypes(0)="word"
    Signature="<optional string Command>"
    Description="Show a list of commands available to players or display info about one specific command"
    bNotifySenderOnSuccess=false
}
