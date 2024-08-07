using System;
using System.IO;
using System.Text.Json;
using System.Text.Json.Serialization;
using System.Threading;
using System.Threading.Tasks;
using Humanizer;

namespace SunfallGame.Code;

public static partial class GameFiles
{
    public const string GAME_NAME = "Sunfall";
    public const string STUDIO_NAME = "RemotePeopleGames";

    static GameFiles()
    {
        string appDataPath = Environment.GetFolderPath(Environment.SpecialFolder.ApplicationData);

        GameDataPath = Path.Combine(appDataPath, STUDIO_NAME, GAME_NAME);
        PlayerSaveFolderPath = Path.Combine(GameDataPath, "Saves");
    }

    public static string GameDataPath { get; }
    public static string PlayerSaveFolderPath { get; }

    public static async Task<PlayerData> LoadPlayerData(string saveName, CancellationToken cancellationToken = default)
    {
        string saveNameSanitized = saveName.Kebaberize();
        string filePath = Path.Combine(PlayerSaveFolderPath, $"{saveNameSanitized}.json");
        if (!File.Exists(filePath)) return new PlayerData();

        await using FileStream readStream = File.OpenRead(filePath);
        PlayerData? data = await JsonSerializer.DeserializeAsync(readStream, ConfiguredJsonSerializedContext.Default.PlayerData, cancellationToken);

        return data ?? new PlayerData();
    }

    public static async Task<GameSettings> LoadSettings(CancellationToken cancellationToken = default)
    {
        string filePath = Path.Combine(GameDataPath, "settings.json");
        if (!File.Exists(filePath)) return new GameSettings();

        await using FileStream readStream = File.OpenRead(filePath);
        GameSettings? settings = await JsonSerializer.DeserializeAsync(readStream,
            ConfiguredJsonSerializedContext.Default.GameSettings,
            cancellationToken);

        return settings ?? new GameSettings();
    }

    public static async Task SavePlayerData(string saveName, PlayerData data, CancellationToken cancellationToken = default)
    {
        string saveNameSanitized = saveName.Kebaberize();
        string filePath = Path.Combine(PlayerSaveFolderPath, $"{saveNameSanitized}.json");

        await using FileStream writeStream = File.OpenWrite(filePath);
        await JsonSerializer.SerializeAsync(writeStream, data, ConfiguredJsonSerializedContext.Default.GameSettings, cancellationToken);
    }

    public static async Task SaveSettings(GameSettings settings, CancellationToken cancellationToken = default)
    {
        string filePath = Path.Combine(GameDataPath, "settings.json");

        await using FileStream writeStream = File.OpenWrite(filePath);
        await JsonSerializer.SerializeAsync(writeStream, settings, ConfiguredJsonSerializedContext.Default.GameSettings, cancellationToken);
    }

    [JsonSourceGenerationOptions(WriteIndented = true)]
    [JsonSerializable(typeof(GameSettings))]
    [JsonSerializable(typeof(PlayerData))]
    private partial class ConfiguredJsonSerializedContext : JsonSerializerContext;
}
