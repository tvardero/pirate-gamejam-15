using System;
using SunfallGame.scenes.characters.player;

namespace SunfallGame.Code;

public static class Game
{
    private static bool _inFuture;
    private static PlayerData? _playerData;

    public static GameSettings Settings { get; set; } = new();
    public static PlayerData PlayerData => _playerData ?? throw new InvalidOperationException("Player data is not set");

    public static bool IsWorldInFuture { get => _inFuture; set => SetTime(value); }

    public static Player? Player { get; set; }

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
