class N7_FakedPlayersModel extends Core.Object within N7_CommandManager;

var protected int FakedPlayersNum;

public final function int GetFakedPlayersNum()
{
    return FakedPlayersNum;
}

public final function SetFakedPlayersNum(int NewFakedPlayersNum)
{
    FakedPlayersNum = NewFakedPlayersNum;
}

public final function int GetRealPlayersNum()
{
    local Controller C;
    local int RealPlayersNum;

    for (C = Level.ControllerList; C != None; C = C.NextController)
    {
        if ((C.IsA('PlayerController') || C.IsA('xBot')) && MessagingSpectator(C) == None)
        {
            RealPlayersNum++;
        }
    }

    return RealPlayersNum;
}

defaultproperties
{
    FakedPlayersNum=0
}
