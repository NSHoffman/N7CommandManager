class N7_RestoredPlayersModel extends Core.Object within N7_CommandManager;

var protected Array<PlayerController> RestoredPlayers;

public final function Array<PlayerController> GetRestoredPlayers()
{
    return RestoredPlayers;
}

public final function RefreshRestoredPlayers()
{
    local PlayerController CurrentPC;
    local int i;

    while (i < RestoredPlayers.Length)
    {
        CurrentPC = RestoredPlayers[i];
        if (CurrentPC == None)
        {
            RestoredPlayers.Remove(i, 1);
            break;
        }
        i++;
    }
}

public final function AddRestoredPlayer(PlayerController PC)
{
    local PlayerController CurrentPC;
    local int i;

    for (i = 0; i < RestoredPlayers.Length; i++)
    {
        CurrentPC = RestoredPlayers[i];
        if (CurrentPC == PC)
        {
            return;
        }
    }

    RestoredPlayers[RestoredPlayers.Length] = PC;
}

public final function RemoveRestoredPlayer(PlayerController PC)
{
    local PlayerController CurrentPC;
    local int i;

    for (i = 0; i < RestoredPlayers.Length; i++)
    {
        CurrentPC = RestoredPlayers[i];
        if (CurrentPC == PC)
        {
            RestoredPlayers.Remove(i, 1);
            return;
        }
    }
}

public final function PlayerController FindRestoredPlayer(PlayerController PC)
{
    local PlayerController CurrentPC;
    local int i;

    for (i = 0; i < RestoredPlayers.Length; i++)
    {
        CurrentPC = RestoredPlayers[i];
        if (CurrentPC == PC)
        {
            return CurrentPC;
        }
    }

    return None;
}

defaultproperties
{}
