using Godot;

namespace SunfallGame.scenes.dialogue.portraits;

public partial class PortraitSprite : Sprite2D
{
    [Export] public AnimationPlayer AnimationPlayer;
    [Export] public bool Continuous {get; private set;}

    public override void _Ready()
    {
        AnimationPlayer = GetNode<AnimationPlayer>("AnimationPlayer");

        Centered = false;
        Offset = new Vector2(Offset.X, -Texture.GetHeight());

        if (AnimationPlayer != null)
        {
            SetAnimation();
        }
    }

    private void SetAnimation()
    {
        foreach(string animationName in AnimationPlayer.GetAnimationList())
        {
            if (animationName.Equals("RESET")) continue;

            AnimationPlayer.AssignedAnimation = animationName;
        }
    }

}