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
                    Commands[i].GetHelp(ExecState.GetSender());
                }
            }
            break;

        case 1:
            CommandString = ExecState.GetArg(ECmdArgs.ARG_COMMAND);
            RequestedCommand = GetCommand(CommandString);

            RequestedCommand.GetHelp(ExecState.GetSender());
            RequestedCommand.GetExtendedHelp(ExecState.GetSender());
            break;
    }
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local string CommandString;
    local KFTHPCommand RequestedCommand;

    if (ExecState.GetArgC() == 1)
    {
        CommandString = ExecState.GetArg(ECmdArgs.ARG_COMMAND);
        RequestedCommand = GetCommand(CommandString);

        return RequestedCommand != None && ShouldDisplayHelpForCommand(RequestedCommand);
    }

    return true;
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
    return "Unavailable command";
}

defaultproperties
{
    MinArgsNum=0
    MaxArgsNum=1
    Aliases(0)="HELP"
    ArgTypes(0)="word"
    Signature="<? string Command>"
    Description="Show list of commands available to players or display extended info about one specific command"
    bNotifySenderOnSuccess=false
    bOnlyPlayerSender=false
}
