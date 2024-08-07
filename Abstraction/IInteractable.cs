using Godot;

namespace SunfallGame.Abstraction;

/// <summary>
/// Interface specifying that the object can be interacted with (by player or by other entities).
/// </summary>
public interface IInteractable
{
    /// <inheritdoc cref="Node2D.GlobalPosition"/>
    Vector2 GlobalPosition { get; }

    /// <summary>
    /// Ends current interaction with this object.
    /// </summary>
    /// <param name="initiator">Entity that was interacting with this object.</param>
    void EndInteraction(Node2D initiator);

    /// <summary>
    /// Starts interaction with this object.
    /// </summary>
    /// <param name="initiator">Entity that interacts with this object.</param>
    void StartInteraction(Node2D initiator);
}
