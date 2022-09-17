class N7_SummonCommand extends N7_BinaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (N7_CommandExecutionState ExecState, PlayerController PC)
{
    local class<KFMonster> TargetZedClass;
    local KFMonster SpawnedZed;

    TargetZedClass = class<KFMonster>(
        DynamicLoadObject(ExecState.LoadString(), class'Class')
    );

    SpawnedZed = Spawn(TargetZedClass,,, PC.Pawn.Location + 72 * Vector(PC.Rotation) + vect(0, 0, 1) * 15);
    ExecState.SaveString(TargetZedClass.default.MenuName);
    
    if (SpawnedZed == None)
    {
        ExecState.SetErrorRuntime();
    }
}

/** @Override */
protected function bool CheckGameState(N7_CommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function bool CheckArgs(N7_CommandExecutionState ExecState)
{
    local string TargetZed;
    local int i;

    TargetZed = ExecState.GetArg(ECmdArgs.ARG_VALUE);

    for (i = 0; i < KFGT.MonsterCollection.default.MonsterClasses.Length; i++)
    {
        if (IsStringPartOf(TargetZed, KFGT.MonsterCollection.default.MonsterClasses[i].MClassName))
        {
            ExecState.SaveString(KFGT.MonsterCollection.default.MonsterClasses[i].MClassName);
            return True;
        }

        if (IsStringPartOf(TargetZed, KFGT.MonsterCollection.default.EndGameBossClass))
        {
            ExecState.SaveString(KFGT.MonsterCollection.default.EndGameBossClass);
            return True;
        }
    }

    return False;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Cannot spawn ZEDs when game is not in progress";
}

/** @Override */
protected function string RuntimeErrorMessage(N7_CommandExecutionState ExecState)
{
    return "Could not summon "$ColorizeValue(ExecState.LoadString());
}

/** @Override */
protected function string InvalidArgsMessage(N7_CommandExecutionState ExecState)
{
    return "Cannot find ZED with class "$ColorizeValue(ExecState.GetArg(ECmdArgs.ARG_VALUE));
}

/** @Override */
protected function string GetSenderSuccessMessage(N7_CommandExecutionState ExecState)
{
    return ColorizeValue(ExecState.LoadString())$" has been spawned";
}

/** @Override */
protected function string GetTargetSuccessMessage(N7_CommandExecutionState ExecState)
{
    return ColorizeValue(ExecState.LoadString())$" has been spawned next to you";
}

defaultproperties
{
    bAdminOnly=True
    MinArgsNum=1
    Aliases(0)="SUMMON"
    ArgTypes(0)="any"
    Signature="<string ZedClass, ? string TargetName>"
    Description="Spawn ZED next to a player"
    bAllowTargetAll=False
    bOnlyAliveTargets=True
}
