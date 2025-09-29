class N7_InfiniteAmmoPlayersModel extends Core.Object within N7_CommandManager;

var protected Array<string> InfiniteAmmoPlayers;

public final function Array<string> GetInfiniteAmmoPlayers()
{
	return InfiniteAmmoPlayers;
}

public final function AddInfiniteAmmoPlayer(PlayerController PC)
{
	if (FindInfiniteAmmoPlayer(PC) == "")
	{
		InfiniteAmmoPlayers[InfiniteAmmoPlayers.Length] = PC.GetPlayerIDHash();
	}
}

public final function RemoveInfiniteAmmoPlayer(PlayerController PC)
{
	local int i;

	for (i = 0; i < InfiniteAmmoPlayers.Length; i++)
	{
		if (InfiniteAmmoPlayers[i] == PC.GetPlayerIDHash())
		{
			InfiniteAmmoPlayers.Remove(i, 1);
			return;
		}
	}
}

public final function string FindInfiniteAmmoPlayer(PlayerController PC)
{
	local int i;

	for (i = 0; i < InfiniteAmmoPlayers.Length; i++)
	{
		if (InfiniteAmmoPlayers[i] == PC.GetPlayerIDHash())
		{
			return InfiniteAmmoPlayers[i];
		}
	}

	return "";
}

defaultproperties
{
}
