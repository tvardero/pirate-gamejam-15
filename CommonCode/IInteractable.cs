using Godot;

namespace SunfallGame.CommonCode;

public interface IInteractable
{
    Vector2 Position { get; }
    void StartInteraction(Node2D initiator);
    void EndInteraction(Node2D initiator);
}

public interface IPushable
{
    void PushByDistance(Vector2 distance);
}
