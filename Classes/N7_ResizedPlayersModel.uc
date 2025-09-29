class N7_ResizedPlayersModel extends Core.Object within N7_CommandManager;

struct ResizedPlayer 
{
    var string Hash;
    var float ResizeMultiplier;
};

var protected Array<ResizedPlayer> ResizedPlayers;

public final function Array<ResizedPlayer> GetResizedPlayers()
{
    return ResizedPlayers;
}

public final function RefreshResizedPlayers()
{
    local Controller C;
    local PlayerController PC;
    local int i;

    i = 0;
    while (i < ResizedPlayers.Length)
    {
        PC = None;

        for (C = Level.ControllerList; C != None; C = C.NextController)
        {
            if (PlayerController(C) != None && PlayerController(C).GetPlayerIDHash() == ResizedPlayers[i].Hash)
            {
                PC = PlayerController(C);
                break;
            }
        }

        if (PC == None || PC.Pawn == None || PC.Pawn.Health <= 0 || ResizedPlayers[i].ResizeMultiplier == 1.0)
        {
            ResizedPlayers.Remove(i, 1);
            continue;
        }

        i++;
    }
}

public final function AddResizedPlayer(PlayerController PC, float ResizeMultiplier)
{
    local ResizedPlayer RP;
    local ResizedPlayer NewPlayer;
    local int i;

    RP = FindResizedPlayer(PC);

    if (RP.Hash == "")
    {
        NewPlayer.Hash = PC.GetPlayerIDHash();
        NewPlayer.ResizeMultiplier = ResizeMultiplier;

        ResizedPlayers[ResizedPlayers.Length] = NewPlayer;
    } 
    else 
    {
        for (i = 0; i < ResizedPlayers.Length; i++)
        {
            if (ResizedPlayers[i].Hash == PC.GetPlayerIDHash())
            {
                ResizedPlayers[i].ResizeMultiplier = ResizeMultiplier;
                return;
            }
        }
    }
}

public final function RemoveResizedPlayer(PlayerController PC)
{
    local int i;

    for (i = 0; i < ResizedPlayers.Length; i++)
    {
        if (ResizedPlayers[i].Hash == PC.GetPlayerIDHash())
        {
            ResizedPlayers.Remove(i, 1);
            return;
        }
    }
}

public final function ResizedPlayer FindResizedPlayer(PlayerController PC)
{
    local int i;
    local ResizedPlayer Result;

    for (i = 0; i < ResizedPlayers.Length; i++)
    {
        if (ResizedPlayers[i].Hash == PC.GetPlayerIDHash())
        {
            return ResizedPlayers[i];
        }
    }

    Result.Hash = "";
    Result.ResizeMultiplier = 1.0;

    return Result;
}


defaultproperties
{
}
