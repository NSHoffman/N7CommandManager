class KFTHPSummonCommand extends KFTHPBinaryTargetCommand;

/** @Override */
protected function DoActionForSingleTarget
    (KFTHPCommandExecutionState ExecState, PlayerController PC)
{
    local class<KFMonster> TargetZedClass;
    local KFMonster SpawnedZed;

    TargetZedClass = class<KFMonster>(
        DynamicLoadObject(KFTHPCommandPreservedState(ExecState).LoadString(), class'Class')
    );

    SpawnedZed = Spawn(TargetZedClass,,, PC.Pawn.Location + 72 * Vector(PC.Rotation) + vect(0, 0, 1) * 15);
    KFTHPCommandPreservedState(ExecState).SaveString(TargetZedClass.default.MenuName);
    
    if (SpawnedZed == None)
    {
        ExecState.SetErrorRuntime();
    }
}

/** @Override */
protected function bool CheckGameState(KFTHPCommandExecutionState ExecState)
{
    return KFGT.IsInState('MatchInProgress');
}

/** @Override */
protected function bool CheckArgs(KFTHPCommandExecutionState ExecState)
{
    local string TargetZed;
    local int i;

    TargetZed = ExecState.GetArg(ECmdArgs.ARG_VALUE);

    for (i = 0; i < KFGT.MonsterCollection.default.MonsterClasses.Length; i++)
    {
        if (IsStringPartOf(TargetZed, KFGT.MonsterCollection.default.MonsterClasses[i].MClassName))
        {
            KFTHPCommandPreservedState(ExecState).SaveString(KFGT.MonsterCollection.default.MonsterClasses[i].MClassName);
            return true;
        }

        if (IsStringPartOf(TargetZed, KFGT.MonsterCollection.default.EndGameBossClass))
        {
            KFTHPCommandPreservedState(ExecState).SaveString(KFGT.MonsterCollection.default.EndGameBossClass);
            return true;
        }
    }

    return false;
}

/** @Override */
protected function string InvalidGameStateMessage()
{
    return "Cannot spawn ZEDs when game is not in progress";
}

/** @Override */
protected function string RuntimeErrorMessage(KFTHPCommandExecutionState ExecState)
{
    return "Could not summon "$KFTHPCommandPreservedState(ExecState).LoadString();
}

/** @Override */
protected function string InvalidArgsMessage(KFTHPCommandExecutionState ExecState)
{
    return "Cannot find ZED with class "$ExecState.GetArg(ECmdArgs.ARG_VALUE);
}

/** @Override */
protected function string GetSenderSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return KFTHPCommandPreservedState(ExecState).LoadString()$" has been spawned";
}

/** @Override */
protected function string GetTargetSuccessMessage(KFTHPCommandExecutionState ExecState)
{
    return KFTHPCommandPreservedState(ExecState).LoadString()$" has been spawned next to you";
}

defaultproperties
{
    bAdminOnly=true
    MinArgsNum=1
    Aliases(0)="SUMMON"
    ArgTypes(0)="any"
    Signature="<string ZedClass, ? string TargetName>"
    Description="Spawn ZED next to a player"
    bAllowTargetAll=false
    bOnlyAliveTargets=true
}
