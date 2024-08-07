using System;
using System.Collections.Generic;
using SunfallGame.scenes.characters.player;

namespace SunfallGame.CommonCode;

public static class WorldState
{
    private static bool _inFuture;

    public static Dictionary<string, LevelState> LevelStates { get; } = new();

    public static bool IsWorldInFuture { get => _inFuture; set => SetTime(value); }

    public static Player Player { get; set; }
    
    public static void LoadFromFile(string saveName)
    {
        throw new NotImplementedException();
    }

    public static void SaveToFile(string saveName)
    {
        throw new NotImplementedException();
    }

    public static bool SwitchTime()
    {
        IsWorldInFuture = !IsWorldInFuture;
        return IsWorldInFuture;
    }

    private static void SetTime(bool inFuture)
    {
        _inFuture = inFuture;
    }
}
