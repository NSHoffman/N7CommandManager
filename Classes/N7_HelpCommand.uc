class N7_HelpCommand extends N7_Command;

enum ECmdArgs
{
    ARG_COMMAND,
};

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local string CommandString;
    local N7_Command RequestedCommand;
    local int i;

    switch (ExecState.GetArgC())
    {
        case 0:
            for (i = 0; i < Commands.Length; i++)
            {
                if (Commands[i] != None && ShouldDisplayHelpForCommand(Commands[i]))
                {
                    Commands[i].Help(ExecState.GetSender());
                }
            }
            break;

        case 1:
            CommandString = ExecState.GetArg(ECmdArgs.ARG_COMMAND);
            RequestedCommand = GetCommand(CommandString);

            RequestedCommand.Help(ExecState.GetSender());
            RequestedCommand.ExtendedHelp(ExecState.GetSender());
            break;
    }
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local string CommandString;
    local N7_Command RequestedCommand;

    if (ExecState.GetArgC() == 1)
    {
        CommandString = ExecState.GetArg(ECmdArgs.ARG_COMMAND);
        RequestedCommand = GetCommand(CommandString);

        return RequestedCommand != None && ShouldDisplayHelpForCommand(RequestedCommand);
    }

    return True;
}

protected function bool ShouldDisplayHelpForCommand(N7_Command Command)
{
    return !Command.IsAdminOnly();
}

protected function N7_Command GetCommand(string CommandString)
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
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Unavailable command";
}

defaultproperties
{
    Aliases(0)="HELP"
    ArgTypes(0)="word"
    MinArgsNum=0
    MaxArgsNum=1
    Signature="<? string Command>"
    Description="Show list of commands available to players or display extended info about one specific command"
    bNotifySenderOnSuccess=False
    bOnlyPlayerSender=False
}
