class N7_GiveWeaponCommand extends N7_BinaryTargetCommand;

var protected config const Array<string> AvailableWeaponClasses;
var protected class<Weapon> WeaponClass;

var protected config const int MaxWeightLimit;

/** @Override */
protected function DoActionForSingleTarget(N7_CommandExecutionState ExecState, PlayerController PC)
{
    local KFWeapon NewWeapon;
    local int i;
    local class<Weapon> WClass;
    local KFHumanPawn KFP;

    KFP = KFHumanPawn(PC.Pawn);

    if (WeaponClass == None)
    {
        for (i = 0; i < AvailableWeaponClasses.Length; i++)
        {
            if (KFP.CurrentWeight > MaxWeightLimit)
            {
                return;
            }

            WClass = class<Weapon>(DynamicLoadObject(AvailableWeaponClasses[i], class'Class'));
            
            if (WClass == None || KFP.FindInventoryType(WClass) != None)
            {
                continue;
            }

            NewWeapon = KFWeapon(KFP.Spawn(WClass));

            if (NewWeapon != None)
            {
                NewWeapon.GiveTo(KFP);
            }
        }
    }
    else
    {
        NewWeapon = KFWeapon(KFP.Spawn(WeaponClass));

        if (NewWeapon != None)
        {
            NewWeapon.GiveTo(KFP);
        }
    }
}

protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local string WeaponName;
    local int i;
    local float NearestWeaponMatchRatio, CurrentMatchRatio;
    local string NearestWeaponClassName;

    WeaponName = ExecState.GetArg(ECmdArgs.ARG_VALUE);

    if (WeaponName ~= "all")
    {
        WeaponClass = None;
        return True;
    }

    for (i = 0; i < AvailableWeaponClasses.Length; i++)
    {
        CurrentMatchRatio = GetStringMatchRatio(WeaponName, AvailableWeaponClasses[i]);

        if (CurrentMatchRatio > NearestWeaponMatchRatio)
        {
            NearestWeaponMatchRatio = CurrentMatchRatio;
            NearestWeaponClassName = AvailableWeaponClasses[i];
        }
    }

    if (NearestWeaponClassName != "")
    {
        WeaponClass = class<Weapon>(DynamicLoadObject(NearestWeaponClassName, class'Class'));
        return WeaponClass != None;
    }

    return False;
}

/** @Override */
protected function bool CheckTargetCustom(N7_CommandExecutionState ExecState, PlayerController Target)
{
    if (WeaponClass == None)
    {
        if (KFHumanPawn(Target.Pawn).CurrentWeight > MaxWeightLimit)
        {
            return False;
        }
    }

    return Target.Pawn.FindInventoryType(WeaponClass) == None;
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Invalid weapon. Use 'help' to get the full list of available weapons";
}

/** @Override */
protected function string InvalidTargetMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName;

    TargetName = ColorizeTarget(LoadTarget(ExecState));

    if (WeaponClass == None)
    {
        return "Player "$TargetName$" not found or already fully equipped";
    }

    return "Player "$TargetName$" not found or already has the specified weapon";
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, WeaponStatus;

    TargetName = LoadTarget(ExecState);

    if (WeaponClass == None)
    {
        WeaponStatus = "fully equipped";
    }
    else
    {
        WeaponStatus = "given "$ColorizeEntity(WeaponClass.Default.ItemName);
    }

    if (TargetName == "all")
    {
        return "All players have been "$WeaponStatus;
    }

    return "You have been "$WeaponStatus;
}

/** @Override */
protected function string GetGlobalSuccessMessage(N7_CommandExecutionState ExecState)
{
    local string TargetName, WeaponStatus;

    TargetName = LoadTarget(ExecState);

    if (WeaponClass == None)
    {
        WeaponStatus = "fully equipped";
    }
    else
    {
        WeaponStatus = "given "$ColorizeEntity(WeaponClass.Default.ItemName);
    }

    if (TargetName == "all")
    {
        return "All players have been "$WeaponStatus;
    }

    return ColorizeTarget(TargetName)$" has been "$WeaponStatus;
}

/** @Override */
protected function ExtendedHelp(PlayerController PC)
{
    local int i;
    HelpSectionSeparator(PC, "Available Weapons");

    for (i = 0; i < AvailableWeaponClasses.Length; i++)
    {
        SendMessage(PC, AvailableWeaponClasses[i]);
    }
}

/** @Override */
protected function Cleanup()
{
    WeaponClass = None;
}

defaultproperties
{
    MinArgsNum=1
    ArgTypes(0)="any"

    MaxWeightLimit=100

    AvailableWeaponClasses(0)="KFMod.AA12AutoShotgun"
    AvailableWeaponClasses(1)="KFMod.AK47AssaultRifle"
    AvailableWeaponClasses(2)="KFMod.Axe"
    AvailableWeaponClasses(3)="KFMod.BenelliShotgun"
    AvailableWeaponClasses(4)="KFMod.BlowerThrower"
    AvailableWeaponClasses(5)="KFMod.BoomStick"
    AvailableWeaponClasses(6)="KFMod.Bullpup"
    AvailableWeaponClasses(7)="KFMod.CamoM4AssaultRifle"
    AvailableWeaponClasses(8)="KFMod.CamoM32GrenadeLauncher"
    AvailableWeaponClasses(9)="KFMod.CamoMP5MMedicGun"
    AvailableWeaponClasses(10)="KFMod.CamoShotgun"
    AvailableWeaponClasses(11)="KFMod.Chainsaw"
    AvailableWeaponClasses(12)="KFMod.ClaymoreSword"
    AvailableWeaponClasses(13)="KFMod.Crossbow"
    AvailableWeaponClasses(14)="KFMod.Crossbuzzsaw"
    AvailableWeaponClasses(15)="KFMod.Deagle"
    AvailableWeaponClasses(16)="KFMod.Dual44Magnum"
    AvailableWeaponClasses(17)="KFMod.DualDeagle"
    AvailableWeaponClasses(18)="KFMod.DualFlareRevolver"
    AvailableWeaponClasses(19)="KFMod.Dualies"
    AvailableWeaponClasses(20)="KFMod.DualMK23Pistol"
    AvailableWeaponClasses(21)="KFMod.DwarfAxe"
    AvailableWeaponClasses(22)="KFMod.FlameThrower"
    AvailableWeaponClasses(23)="KFMod.FlareRevolver"
    AvailableWeaponClasses(24)="KFMod.FNFAL_ACOG_AssaultRifle"
    AvailableWeaponClasses(25)="KFMod.GoldenAA12AutoShotgun"
    AvailableWeaponClasses(26)="KFMod.GoldenAK47AssaultRifle"
    AvailableWeaponClasses(27)="KFMod.GoldenBenelliShotgun"
    AvailableWeaponClasses(28)="KFMod.GoldenChainsaw"
    AvailableWeaponClasses(29)="KFMod.GoldenDeagle"
    AvailableWeaponClasses(30)="KFMod.GoldenDualDeagle"
    AvailableWeaponClasses(31)="KFMod.GoldenFlamethrower"
    AvailableWeaponClasses(32)="KFMod.GoldenKatana"
    AvailableWeaponClasses(33)="KFMod.GoldenM79GrenadeLauncher"
    AvailableWeaponClasses(34)="KFMod.HuskGun"
    AvailableWeaponClasses(35)="KFMod.Katana"
    AvailableWeaponClasses(36)="KFMod.Knife"
    AvailableWeaponClasses(37)="KFMod.KrissMMedicGun"
    AvailableWeaponClasses(38)="KFMod.KSGShotgun"
    AvailableWeaponClasses(39)="KFMod.LAW"
    AvailableWeaponClasses(40)="KFMod.M4AssaultRifle"
    AvailableWeaponClasses(41)="KFMod.M7A3MMedicGun"
    AvailableWeaponClasses(42)="KFMod.M14EBRBattleRifle"
    AvailableWeaponClasses(43)="KFMod.M32GrenadeLauncher"
    AvailableWeaponClasses(44)="KFMod.M79GrenadeLauncher"
    AvailableWeaponClasses(45)="KFMod.M99SniperRifle"
    AvailableWeaponClasses(46)="KFMod.M4203AssaultRifle"
    AvailableWeaponClasses(47)="KFMod.MAC10MP"
    AvailableWeaponClasses(48)="KFMod.Machete"
    AvailableWeaponClasses(49)="KFMod.Magnum44Pistol"
    AvailableWeaponClasses(50)="KFMod.MK23Pistol"
    AvailableWeaponClasses(51)="KFMod.MKb42AssaultRifle"
    AvailableWeaponClasses(52)="KFMod.MP5MMedicGun"
    AvailableWeaponClasses(53)="KFMod.MP7MMedicGun"
    AvailableWeaponClasses(54)="KFMod.NailGun"
    AvailableWeaponClasses(55)="KFMod.NeonAK47AssaultRifle"
    AvailableWeaponClasses(56)="KFMod.NeonKrissMMedicGun"
    AvailableWeaponClasses(57)="KFMod.NeonKSGShotgun"
    AvailableWeaponClasses(58)="KFMod.NeonSCARMK17AssaultRifle"
    AvailableWeaponClasses(59)="KFMod.PipeBombExplosive"
    AvailableWeaponClasses(60)="KFMod.SCARMK17AssaultRifle"
    AvailableWeaponClasses(61)="KFMod.Scythe"
    AvailableWeaponClasses(62)="KFMod.SealSquealHarpoonBomber"
    AvailableWeaponClasses(63)="KFMod.SeekerSixRocketLauncher"
    AvailableWeaponClasses(64)="KFMod.Single"
    AvailableWeaponClasses(65)="KFMod.SPAutoShotgun"
    AvailableWeaponClasses(66)="KFMod.SPGrenadeLauncher"
    AvailableWeaponClasses(67)="KFMod.SPSniperRifle"
    AvailableWeaponClasses(68)="KFMod.SPThompsonSMG"
    AvailableWeaponClasses(69)="KFMod.Syringe"
    AvailableWeaponClasses(70)="KFMod.ThompsonDrumSMG"
    AvailableWeaponClasses(71)="KFMod.ThompsonSMG"
    AvailableWeaponClasses(72)="KFMod.Trenchgun"
    AvailableWeaponClasses(73)="KFMod.Welder"
    AvailableWeaponClasses(74)="KFMod.Winchester"
    AvailableWeaponClasses(75)="KFMod.ZEDGun"
    AvailableWeaponClasses(76)="KFMod.ZEDMKIIWeapon"
    AvailableWeaponClasses(77)="KFMod.Shotgun"

    Aliases(0)="GW"
    Aliases(1)="WEAPON"
    Aliases(2)="GIVEWEAPON"
    Description="Give weapon to the player"
    Signature="<string Weapon, ? (string TargetName | 'all')>"

    bNotifyGlobalOnSuccess=True
    
    bOnlyAliveTargets=True

    bAdminOnly=True
}
