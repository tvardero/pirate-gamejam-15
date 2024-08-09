using System.Runtime.CompilerServices;
using System.Text.Json;
using System.Text.Json.Serialization;

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

    public static async Task<PlayerData?> LoadPlayerDataAsync(string saveFileName, CancellationToken cancellationToken = default)
    {
        var absolutePath = Path.Combine(PlayerSaveFolderPath, saveFileName);
        if (!File.Exists(absolutePath)) return null;

        FileStream readStream = File.OpenRead(absolutePath);
        await using ConfiguredAsyncDisposable stream = readStream.ConfigureAwait(false);

        PlayerData? data = await JsonSerializer
            .DeserializeAsync(readStream, ConfiguredJsonSerializedContext.Default.PlayerData, cancellationToken)
            .ConfigureAwait(false);

        return data;
    }

    public static async Task<GameSettings> LoadSettingsAsync(CancellationToken cancellationToken = default)
    {
        string absolutePath = Path.Combine(GameDataPath, "settings.json");
        if (!File.Exists(absolutePath)) return new GameSettings();

        FileStream readStream = File.OpenRead(absolutePath);
        await using ConfiguredAsyncDisposable stream = readStream.ConfigureAwait(false);

        GameSettings? settings = await JsonSerializer
            .DeserializeAsync(readStream,
                ConfiguredJsonSerializedContext.Default.GameSettings,
                cancellationToken)
            .ConfigureAwait(false);

        return settings ?? new GameSettings();
    }

    public static async Task SavePlayerDataAsync(PlayerData data, CancellationToken cancellationToken = default)
    {
        string absolutePath = Path.Combine(PlayerSaveFolderPath, data.SaveFileName);

        FileStream writeStream = File.OpenWrite(absolutePath);
        await using ConfiguredAsyncDisposable stream = writeStream.ConfigureAwait(false);

        await JsonSerializer
            .SerializeAsync(writeStream, data, ConfiguredJsonSerializedContext.Default.GameSettings, cancellationToken)
            .ConfigureAwait(false);
    }

    public static async Task SaveSettingsAsync(GameSettings settings, CancellationToken cancellationToken = default)
    {
        string absolutePath = Path.Combine(GameDataPath, "settings.json");

        FileStream writeStream = File.OpenWrite(absolutePath);
        await using ConfiguredAsyncDisposable stream = writeStream.ConfigureAwait(false);

        await JsonSerializer
            .SerializeAsync(writeStream, settings, ConfiguredJsonSerializedContext.Default.GameSettings, cancellationToken)
            .ConfigureAwait(false);
    }

    public static async IAsyncEnumerable<PlayerData> LoadAllSaveFilesAsync([EnumeratorCancellation] CancellationToken cancellationToken = default)
    {
        string[] files = Directory.GetFiles(PlayerSaveFolderPath);
        foreach (string file in files)
        {
            var fi = new FileInfo(file);
            if (fi.Extension != ".json") continue;

            PlayerData? save = await LoadPlayerDataAsync(fi.Name + fi.Extension, cancellationToken);
            if (save == null) continue;

            yield return save;
        }
    }

    [JsonSourceGenerationOptions(WriteIndented = true)]
    [JsonSerializable(typeof(GameSettings))]
    [JsonSerializable(typeof(PlayerData))]
    private partial class ConfiguredJsonSerializedContext : JsonSerializerContext;
}
