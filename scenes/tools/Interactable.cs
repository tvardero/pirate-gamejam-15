using Godot;
using SunfallGame.Abstraction;

public partial class Interactable : Area2D, IInteractable
{
    public event Action<Node2D>? InteractionStarted;
    public event Action<Node2D>? InteractionEnded;

    /// <inheritdoc />
    public void EndInteraction(Node2D initiator)
    {
        InteractionStarted?.Invoke(initiator);
    }

    /// <inheritdoc />
    public void StartInteraction(Node2D initiator)
    {
        InteractionEnded?.Invoke(initiator);
    }
}
