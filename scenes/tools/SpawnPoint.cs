using Godot;

namespace SunfallGame.Code;

public partial class SpawnPoint : Node2D
{
    [Export] public int Id { get; set; }
    [Export] public Vector2 FacingDirection { get; set; } = Vector2.Down;
}
