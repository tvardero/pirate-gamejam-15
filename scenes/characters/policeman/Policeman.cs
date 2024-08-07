using Godot;
using SunfallGame.Abstraction;
using SunfallGame.Code;
using SunfallGame.scenes.characters.player;

public partial class Policeman : StaticBody2D, IInteractable
{
    private Resource _dialogueResource = null!;

    /// <inheritdoc />
    public override void _Ready()
    {
        _dialogueResource = GD.Load("res://scenes/dialogue/PoliceOfficer.dialogue");
    }

    /// <inheritdoc />
    public void StartInteraction(Node2D initiator)
    {
        if (initiator is not Player player) return;

        if (Game.PlayerData.NewspaperPickedUp)
        {
            if (Game.PlayerData.PolicemanQuestActive)
            {
                // todo: play dialog "police_officer_first_time_after_newspaper"
            }
            else
            {
                // todo: play dialog "police_after_finding_newspaper"
            }

            QueueFree();
        }
        else
        {
            // todo: play dialog "police_officer"
            Game.PlayerData.PolicemanQuestActive = true;
        }
    }

    /// <inheritdoc />
    public void EndInteraction(Node2D initiator) { }
}
