using System.Linq;
using Godot;
using SunfallGame.Abstraction;
using SunfallGame.Code;

namespace SunfallGame.scenes.characters.player;

public partial class PlayerInputController : Node
{
    private readonly string[] _movementActionNames =
    [
        InputActionNames.MOVE_UP, InputActionNames.MOVE_DOWN,
        InputActionNames.MOVE_LEFT, InputActionNames.MOVE_RIGHT,
    ];

    private Player? _playerCached;
    private AnimationTree? _animationTreeCached;
    private bool _sprinting;

    [Export] public bool Enabled { get; set; } = true;
    [Export] public float WalkingSpeed { get; set; } = 80;
    [Export] public float SprintingSpeed { get; set; } = 120;
    [Export] public float PushSpeed { get; set; } = 20;
    [Export] public float InputDeadZone { get; set; } = 0.12f;

    private Player Player
    {
        get
        {
            _playerCached ??= GetParent<Player>();
            return _playerCached;
        }
    }

    /// <inheritdoc />
    public override void _PhysicsProcess(double delta)
    {
        Vector2 inputVector = Input.GetVector(InputActionNames.MOVE_LEFT,
            InputActionNames.MOVE_RIGHT,
            InputActionNames.MOVE_UP,
            InputActionNames.MOVE_DOWN,
            InputDeadZone);

        bool isWalking = inputVector.LengthSquared() > 0;
        if (isWalking) Player.FacingDirection = inputVector;

        Player.AnimationTree.Set("parameters/conditions/is_walking", isWalking);
        Player.AnimationTree.Set("parameters/conditions/is_idle", !isWalking);

        bool isSprinting = Input.IsActionPressed(InputActionNames.SPRINT);
        float speedMulti = isSprinting ? SprintingSpeed : WalkingSpeed;

        Player.Velocity = inputVector.Normalized() * speedMulti;
        bool collided = Player.MoveAndSlide();
        if (!collided) return;

        KinematicCollision2D? collision = Player.GetLastSlideCollision();
        GodotObject collider = collision.GetCollider();
        if (collider is not IPushable pushable) return;

        pushable.PushByDistance(inputVector * (PushSpeed * (float)delta));
    }

    /// <inheritdoc />
    public override void _UnhandledInput(InputEvent inputEvent)
    {
        if (!Enabled) return;

        bool handled = ProcessMovementInputAction(inputEvent)
                    || ProcessSprintInputAction(inputEvent)
                    || ProcessInteractionInputAction(inputEvent)
                    || ProcessLanternInputAction(inputEvent);

        if (handled) GetTree().Root.SetInputAsHandled();
    }

    private static bool ProcessSprintInputAction(InputEvent inputEvent)
    {
        return inputEvent.IsAction(InputActionNames.SPRINT);
    }

    private bool ProcessInteractionInputAction(InputEvent inputEvent)
    {
        if (!inputEvent.IsAction(InputActionNames.INTERACTION)) return false;

        Player.Interacting = inputEvent.IsPressed();
        return true;
    }

    private bool ProcessLanternInputAction(InputEvent inputEvent)
    {
        if (!inputEvent.IsAction(InputActionNames.LANTERN)) return false;

        if (inputEvent.IsPressed() && !inputEvent.IsEcho()) Player.UseLantern();

        return true;
    }

    private bool ProcessMovementInputAction(InputEvent inputEvent)
    {
        return _movementActionNames.Any(actionName => inputEvent.IsAction(actionName));
    }
}
