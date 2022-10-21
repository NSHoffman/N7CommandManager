class N7_ResizedPlayersModel extends Core.Object within N7_CommandManager;

struct ResizedPlayer
{
    var PlayerController PC;
    var float ResizeMultiplier;
};

var protected Array<ResizedPlayer> ResizedPlayers;

public final function Array<ResizedPlayer> GetResizedPlayers()
{
    return ResizedPlayers;
}

public final function RefreshResizedPlayers()
{
    local int i;

    while (i < ResizedPlayers.Length)
    {
        if (ResizedPlayers[i].PC == None || 
            ResizedPlayers[i].PC.Pawn == None || 
            ResizedPlayers[i].PC.Pawn.Health <= 0 || 
            ResizedPlayers[i].ResizeMultiplier == 1.0)
        {
            ResizedPlayers.Remove(i, 1);
            break;
        }
        i++;
    }
}

public final function AddResizedPlayer(PlayerController PC, float ResizeMultiplier)
{
    local ResizedPlayer NewPlayer;
    local int i;

    NewPlayer.PC = PC;
    NewPlayer.ResizeMultiplier = ResizeMultiplier;

    for (i = 0; i < ResizedPlayers.Length; i++)
    {
        if (ResizedPlayers[i].PC == PC)
        {
            ResizedPlayers[i].ResizeMultiplier = ResizeMultiplier;
            return;
        }
    }

    ResizedPlayers[ResizedPlayers.Length] = NewPlayer;
}

public final function RemoveResizedPlayer(PlayerController PC)
{
    local PlayerController CurrentPC;
    local int i;

    for (i = 0; i < ResizedPlayers.Length; i++)
    {
        CurrentPC = ResizedPlayers[i].PC;
        if (CurrentPC == PC)
        {
            ResizedPlayers.Remove(i, 1);
            return;
        }
    }
}

defaultproperties
{}
