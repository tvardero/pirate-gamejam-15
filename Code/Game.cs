using Godot;
using SunfallGame.scenes.characters.player;

namespace SunfallGame.Code;

public partial class Game : Node
{
    private readonly List<PlayerData> _allSaveFiles = new();
    private readonly CancellationTokenSource _gameQuitCts = new();
    private PlayerData? _loadedSaveFile;

    public Game()
    {
        AllSaveFiles = _allSaveFiles.AsReadOnly();
        Instance = this;
    }

    public static Game Instance { get; private set; } = null!;

    public bool IsGameLoaded => _loadedSaveFile != null;

    public Player? CurrentPlayer => CurrentLevel?.GetPlayer();

    public IReadOnlyCollection<PlayerData> AllSaveFiles { get; }
    [Export] protected PackedScene? NewGameFirstLevel { get; set; }
    [Export] protected int NewGameFirstLevelSpawnPointId { get; set; }
    [Export] protected PackedScene? MainMenu { get; set; }

    public GameSettings Settings { get; set; } = new();

    public PlayerData PlayerData => _loadedSaveFile ?? throw new InvalidOperationException("Not in a game, save file is not loaded");
    public LevelBase? CurrentLevel { get; private set; }

    /// <inheritdoc />
    public override void _Notification(int what)
    {
        if (what == NotificationWMCloseRequest || (what == NotificationWMGoBackRequest && !IsGameLoaded))
        {
            _gameQuitCts.Cancel();
            GetTree().Quit();
        }
    }

    /// <inheritdoc />
    public override void _Ready()
    {
        GetTree().AutoAcceptQuit = false;
        GetTree().QuitOnGoBack = false;

        InitializeAsync().Wait(); // todo: check if it softlocks
    }

    public async Task InitializeAsync()
    {
        Settings = await GameFiles.LoadSettingsAsync(_gameQuitCts.Token);
        await LoadAllSaveFilesAsync();
    }

    public async Task ExitToMainMenuAsync(bool saveCurrentGame = true)
    {
        if (_loadedSaveFile != null)
        {
            if (saveCurrentGame) await SaveGameAsync();
            UnloadLevel();

            _loadedSaveFile = null;
        }

        LoadMainMenu();
    }

    public async Task StartNewGameAsync(string saveName, bool saveCurrentGame = true)
    {
        if (NewGameFirstLevel == null) throw new InvalidOperationException("New game first level is not set");

        if (_loadedSaveFile != null)
        {
            if (saveCurrentGame) await SaveGameAsync();
            UnloadLevel();

            _loadedSaveFile = null;
        }
        else UnloadMainMenu();

        var newData = new PlayerData(saveName)
        {
            CurrentLevelPackedScenePath = NewGameFirstLevel.ResourcePath, CurrentLevelSpawnPointId = NewGameFirstLevelSpawnPointId,
        };

        await GameFiles.SavePlayerDataAsync(newData, _gameQuitCts.Token);
        LoadLevel(newData.CurrentLevelPackedScenePath, newData.CurrentLevelSpawnPointId);

        _allSaveFiles.Clear();
        _loadedSaveFile = newData;
    }

    public async Task SaveGameAsync()
    {
        if (_loadedSaveFile == null) return;

        await GameFiles.SavePlayerDataAsync(_loadedSaveFile, _gameQuitCts.Token);
    }

    public async Task LoadSaveFileAsync(string saveName, bool saveCurrentGame = true)
    {
        if (_loadedSaveFile != null)
        {
            if (saveCurrentGame) await SaveGameAsync();
            UnloadLevel();

            _loadedSaveFile = null;
        }
        else UnloadMainMenu();

        if (_allSaveFiles.Count == 0) await LoadAllSaveFilesAsync();

        PlayerData data = _allSaveFiles.Single(data => data.SaveName == saveName);
        LoadLevel(data.CurrentLevelPackedScenePath, data.CurrentLevelSpawnPointId);

        _allSaveFiles.Clear();
        _loadedSaveFile = data;
    }

    private async Task LoadAllSaveFilesAsync()
    {
        _allSaveFiles.Clear();

        await foreach (PlayerData file in GameFiles.LoadAllSaveFilesAsync(_gameQuitCts.Token)) _allSaveFiles.Add(file);
    }

    private void LoadLevel(string packedScenePath, int spawnPoint)
    {
        var levelPacked = GD.Load<PackedScene>(packedScenePath);
        var level = levelPacked.Instantiate<LevelBase>();

        level.SpawnPlayer(spawnPoint);

        Window window = GetTree().Root;
        window.CallDeferred("add_child", level);

        CurrentLevel = level;
    }

    private void UnloadLevel()
    {
        CurrentLevel?.QueueFree();
        CurrentLevel = null;
    }

    private void LoadMainMenu()
    {
        throw new NotImplementedException();
    }

    private void UnloadMainMenu()
    {
        throw new NotImplementedException();
    }
}
