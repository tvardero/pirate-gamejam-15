using Godot;
using System;

public partial class MainMenu : Control
{
    [Export]
    public PackedScene FirstLevel;

    [Export]
    private Button startButton;

    public override void _Ready()
    {
        startButton.GrabFocus();
    }

    public void OnStartPressed()
    {
        StartGame();
        QueueFree();
    }

    private void StartGame()
    {        
	    WorldState.Instance.Reset();
	    //WorldState.transit_player_to_scene(first_level, 0, Vector2.DOWN)
    }
}
