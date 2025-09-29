class N7_TeleportCommand extends N7_Command;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local Actor HitActor;
    local Vector HitNormal, HitLocation;
    local PlayerController Sender;

    Sender = ExecState.GetSender();
    HitActor = Trace(
        HitLocation, 
        HitNormal, 
        Sender.ViewTarget.Location + 10000 * Vector(Sender.Rotation), 
        Sender.ViewTarget.Location, 
        True);

    if (HitActor != None)
    {
        HitLocation = HitLocation + Sender.ViewTarget.CollisionRadius * HitNormal;
    } 
    else
    {
        HitLocation = Sender.ViewTarget.Location + 10000 * Vector(Sender.Rotation);
    }

    Sender.ViewTarget.SetLocation(HitLocation);
    Sender.ViewTarget.PlayTeleportEffect(False, True);
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "You can teleport only during the game";
}

defaultproperties
{
    Aliases(0)="TP"
    Aliases(1)="TELEPORT"
    Description="Teleport to the position being looked at"
    Signature="<>"

    bNotifySenderOnSuccess=False

    bOnlyAliveSender=True

    bAdminOnly=True
}
