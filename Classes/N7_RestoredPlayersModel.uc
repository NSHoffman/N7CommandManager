class N7_RestoredPlayersModel extends Core.Object within N7_CommandManager;

var protected Array<string> RestoredPlayers;

public final function Array<string> GetRestoredPlayers()
{
    return RestoredPlayers;
}

public final function AddRestoredPlayer(PlayerController PC)
{
    if (FindRestoredPlayer(PC) == "")
    {
        RestoredPlayers[RestoredPlayers.Length] = PC.GetPlayerIDHash();
    }
}

public final function RemoveRestoredPlayer(PlayerController PC)
{
    local int i;

    for (i = 0; i < RestoredPlayers.Length; i++)
    {
        if (RestoredPlayers[i] == PC.GetPlayerIDHash())
        {
            RestoredPlayers.Remove(i, 1);
            return;
        }
    }
}

public final function string FindRestoredPlayer(PlayerController PC)
{
    local int i;

    for (i = 0; i < RestoredPlayers.Length; i++)
    {
        if (RestoredPlayers[i] == PC.GetPlayerIDHash())
        {
            return RestoredPlayers[i];
        }
    }

    return "";
}

defaultproperties
{
}
