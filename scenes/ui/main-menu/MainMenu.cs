using Godot;
using SunfallGame.Code;

public partial class MainMenu : Control
{
    [Export] public Button? StartButton { get; set; }

    public override void _Ready()
    {
        if (StartButton != null)
        {
            StartButton.Pressed += StartGame;
            StartButton.GrabFocus();
        }
    }

    private void StartGame()
    {
        var randomName = Guid.NewGuid().ToString("N");
        _ = Game.Instance.StartNewGameAsync(randomName);
    }
}
