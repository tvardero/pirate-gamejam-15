using Godot;
using SunfallGame.scenes.characters.player;

namespace SunfallGame.Code;

public abstract partial class LevelBase : Node2D, IDisposable
{
    private static PackedScene? _playerPacked;
    private readonly SemaphoreSlim _fadeSemaphore = new(0);
    private Player _currentPlayer = null!;
    private Color? _fadeStartColor;
    private Color? _fadeTargetColor;
    private TimeSpan _fadeTotalDuration = TimeSpan.Zero;
    private TimeSpan _fadeElapsedDuration = TimeSpan.Zero;

    [Export] public SpawnPoint? DefaultSpawnPoint { get; set; }

    [Export] public Node2D? PastGroup { get; set; }
    [Export] public Color PastColor { get; set; } = Color.Color8(255, 255, 255);

    [Export] public Node2D? FutureGroup { get; set; }
    [Export] public Color FutureColor { get; set; } = Color.Color8(0, 0, 0);

    /// <inheritdoc />
    public override void _Process(double delta)
    {
        TimeSpan deltaTime = TimeSpan.FromSeconds(delta);
        if (_fadeTargetColor != null) ProcessFade(deltaTime);
    }

    /// <inheritdoc />
    public override void _Ready()
    {
        _playerPacked ??= GD.Load<PackedScene>("res://scenes/characters/player/Player.tscn");
    }

    public async Task FadeToColorAsync(Color color, TimeSpan duration, bool withPlayer)
    {
        _fadeTargetColor = color;
        _fadeStartColor = Modulate;

        await _fadeSemaphore.WaitAsync();
    }

    public Player GetPlayer()
    {
        return _currentPlayer;
    }

    public void SpawnPlayer(int? spawnPointId = null)
    {
        SpawnPoint? spawnPoint = spawnPointId == null
            ? DefaultSpawnPoint
            : GetChildren().OfType<SpawnPoint>().FirstOrDefault(s => s.Id == spawnPointId);

        Vector2 position = spawnPoint?.GlobalPosition ?? Vector2.Zero;
        Vector2 direction = spawnPoint?.FacingDirection ?? Vector2.Down;

        _currentPlayer = _playerPacked!.Instantiate<Player>();
        _currentPlayer.GlobalPosition = position;
        _currentPlayer.FacingDirection = direction;

        CallDeferred("add_child", _currentPlayer);
    }

    /// <inheritdoc />
    protected override void Dispose(bool disposing)
    {
        if (disposing) _fadeSemaphore.Dispose();

        base.Dispose(disposing);
    }

    private void ProcessFade(TimeSpan delta)
    {
        Color start = _fadeStartColor!.Value;
        Color target = _fadeTargetColor!.Value;

        _fadeElapsedDuration += delta;
        if (_fadeElapsedDuration >= _fadeTotalDuration)
        {
            Modulate = target;
            _fadeStartColor = null;
            _fadeTargetColor = null;
            _fadeElapsedDuration = TimeSpan.Zero;
            _fadeTotalDuration = TimeSpan.Zero;

            _fadeSemaphore.Release();
            return;
        }

        double percent = _fadeElapsedDuration / _fadeTotalDuration;
        Modulate = start.Lerp(target, (float)percent);
    }
}
