using System;
using System.Linq;
using Godot;
using SunfallGame.Abstraction;
using SunfallGame.Code;

namespace SunfallGame.scenes.characters.player;

public partial class Player : CharacterBody2D
{
    private bool _interacting;
    private Vector2 _facingDirection;

    public Vector2 FacingDirection { get => _facingDirection; set => SetFacingDirection(value); }

    public bool Interacting { get => _interacting; set => SetInteracting(value); }

    public Camera2D Camera { get; private set; } = null!;
    public AnimationPlayer AnimationPlayer { get; private set; } = null!;
    public AnimationTree AnimationTree { get; private set; } = null!;
    public Area2D InteractionArea { get; private set; } = null!;
    public Area2D CollisionCheckPast { get; private set; } = null!;
    public Area2D CollisionCheckFuture { get; private set; } = null!;
    public IInteractable? CurrentInteractionTarget { get; set; }

    /// <inheritdoc />
    public override void _Ready()
    {
        Camera = GetNode<Camera2D>("Camera2D");
        AnimationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");
        AnimationTree = GetNode<AnimationTree>("AnimationTree");
        InteractionArea = GetNode<Area2D>("InteractionArea");
        CollisionCheckPast = GetNode<Area2D>("CollisionCheckPast");
        CollisionCheckFuture = GetNode<Area2D>("CollisionCheckFuture");

        SetCollisionMasksAndLayers(Game.IsWorldInFuture);
        Game.Player = this;
    }

    public void EndInteraction()
    {
        CurrentInteractionTarget?.EndInteraction(this);
    }

    public TimeSpan PlayLanternUsage()
    {
        string animationName = FacingDirection.X > 0 ? "lantern-right" : "lantern-left";
        float durationSeconds = AnimationPlayer.GetAnimation(animationName).Length;

        AnimationTree.Set("parameters/conditions/lantern", true);

        return TimeSpan.FromSeconds(durationSeconds);
    }

    public void SetCollisionMasksAndLayers(bool toFuture)
    {
        SetCollisionLayerValue(Physics2DLayers.COLLISION_PAST, !toFuture);
        SetCollisionMaskValue(Physics2DLayers.COLLISION_PAST, !toFuture);
        SetCollisionLayerValue(Physics2DLayers.COLLISION_FUTURE, toFuture);
        SetCollisionLayerValue(Physics2DLayers.COLLISION_FUTURE, toFuture);
    }

    public void StartInteraction()
    {
        CurrentInteractionTarget = InteractionArea
            .GetOverlappingBodies()
            .OfType<IInteractable>()
            .MinBy(body => body.GlobalPosition.DistanceTo(GlobalPosition));

        CurrentInteractionTarget?.StartInteraction(this);
    }

    public void UseLantern()
    {
        bool willBeFuture = !Game.IsWorldInFuture;

        Area2D collisionArea = willBeFuture ? CollisionCheckFuture : CollisionCheckPast;
        bool willCollide = collisionArea.GetOverlappingBodies().Count > 0;

        if (willCollide) PlayLanternFailure();
        else Game.SwitchTime();
    }

    private void PlayLanternFailure()
    {
        AnimationTree.Set("parameters/conditions/lantern", true);
    }

    private void SetFacingDirection(Vector2 value)
    {
        _facingDirection = value;
        if (value.LengthSquared() == 0) return;

        AnimationTree.Set("parameters/idle/blend_position", value);
        AnimationTree.Set("parameters/walk/blend_position", value);
        AnimationTree.Set("parameters/lantern/blend_position", value.X);
        AnimationTree.Set("parameters/lantern-fail/blend_position", value.X);
    }

    private void SetInteracting(bool value)
    {
        bool prevState = _interacting;
        _interacting = value;

        if (prevState == value) return;

        if (value) StartInteraction();
        else EndInteraction();
    }
}
