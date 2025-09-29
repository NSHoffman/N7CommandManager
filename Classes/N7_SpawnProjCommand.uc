class N7_SpawnProjCommand extends N7_Command;

enum ECmdArgs
{
    ARG_PROJTYPE,
};

var protected const Array<string> AvailableProjTypes;

/** @Override */
protected function DoAction(N7_CommandExecutionState ExecState)
{
    local string ProjType;
    ProjType = ExecState.LoadString();

    SpawnProjectile(ExecState.GetSender(), ProjType);
}

protected function SpawnProjectile(PlayerController PC, string ProjType)
{
    local class<Projectile> ProjClass;

    switch (ProjType)
    {
        case AvailableProjTypes[0]:
            KFPlayerController(PC).ClientWeaponSpawned(class'KFMod.FlareRevolver', None);
            ProjClass = class'KFMod.FlareRevolverProjectile';
            break;

        case AvailableProjTypes[1]:
            KFPlayerController(PC).ClientWeaponSpawned(class'KFMod.HuskGun', None);
            ProjClass = class'KFMod.HuskGunProjectile_Strong';
            break;

        case AvailableProjTypes[2]:
            KFPlayerController(PC).ClientWeaponSpawned(class'KFMod.M79GrenadeLauncher', None);
            ProjClass = class'KFMod.M79GrenadeProjectile';
            break;

        case AvailableProjTypes[3]:
            KFPlayerController(PC).ClientWeaponSpawned(class'KFMod.SPGrenadeLauncher', None);
            ProjClass = class'KFMod.SPGrenadeProjectile';
            break;

        case AvailableProjTypes[4]:
            KFPlayerController(PC).ClientWeaponSpawned(class'KFMod.LAW', None);
            ProjClass = class'KFMod.LAWProj';
            break;

        case AvailableProjTypes[5]:
            KFPlayerController(PC).ClientWeaponSpawned(class'KFMod.PipeBombExplosive', None);
            ProjClass = class'KFMod.PipeBombProjectile';
            break;

        case AvailableProjTypes[6]:
            KFPlayerController(PC).ClientWeaponSpawned(class'KFMod.NailGun', None);
            ProjClass = class'KFMod.NailGunProjectile';
            break;

        case AvailableProjTypes[7]:
            KFPlayerController(PC).ClientWeaponSpawned(class'KFMod.SealSquealHarpoonBomber', None);
            ProjClass = class'KFMod.SealSquealProjectile';
            break;
        
        case AvailableProjTypes[8]:
            KFPlayerController(PC).ClientWeaponSpawned(class'KFMod.KrissMMedicGun', None);
            ProjClass = class'KFMod.KrissMHealingProjectile';
            break;

        case AvailableProjTypes[9]:
            KFPlayerController(PC).ClientWeaponSpawned(class'KFMod.BlowerThrower', None);
            ProjClass = class'KFMod.BlowerBileProjectile';
            break;

        case AvailableProjTypes[10]:
            KFPlayerController(PC).ClientWeaponSpawned(class'KFMod.BlowerThrower', None);
            ProjClass = class'KFMod.ZedGunProjectile';
            break;
    }

    PC.Spawn(ProjClass, PC,, PC.ViewTarget.Location + 72 * Vector(PC.Rotation) + vect(0, 0, 1) * 15);
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local string ProjType;
    local int i;

    ProjType = ExecState.GetArg(ECmdArgs.ARG_PROJTYPE);

    for (i = 0; i < AvailableProjTypes.Length; i++)
    {
        if (IsStringPartOf(ProjType, AvailableProjTypes[i]))
        {
            ExecState.SaveString(AvailableProjTypes[i]);
            return True;
        }
    }

    return False;
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return !KFGT.IsInState('PendingMatch');
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Unavailable projectile type. Use 'help' to get the full list of available projectiles";
}

/** @Override */
protected function ExtendedHelp(PlayerController PC)
{
    local int i;
    HelpSectionSeparator(PC, "Available Projectiles");

    for (i = 0; i < AvailableProjTypes.Length; i++)
    {
        SendMessage(PC, AvailableProjTypes[i]);
    }
}

defaultproperties
{
    MinArgsNum=1
    MaxArgsNum=1
    ArgTypes(0)="any"

    AvailableProjTypes(0)="KFMod.FlareRevolver"
    AvailableProjTypes(1)="KFMod.HuskGun"
    AvailableProjTypes(2)="KFMod.M79GrenadeLauncher"
    AvailableProjTypes(3)="KFMod.SPGrenadeLauncher"
    AvailableProjTypes(4)="KFMod.LAW"
    AvailableProjTypes(5)="KFMod.PipeBombExplosive"
    AvailableProjTypes(6)="KFMod.NailGun"
    AvailableProjTypes(7)="KFMod.SealSquealHarpoonBomber"
    AvailableProjTypes(8)="KFMod.KrissMMedicGun"
    AvailableProjTypes(9)="KFMod.BlowerThrower"
    AvailableProjTypes(10)="KFMod.ZedGun"

    Aliases(0)="PROJ"
    Description="Spawn projectile"
    Signature="<string ProjType>"

    bNotifySenderOnSuccess=False

    bAdminOnly=True
}
