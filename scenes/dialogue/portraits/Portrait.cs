using Godot;
using System;
using System.Collections.Generic;
using System.Linq;

public partial class Portrait : Control
{
    private List<PortraitSprite> sprites = new List<PortraitSprite>();

    public override void _Ready()
    {
        foreach(var child in GetChildren())
        {
            if (child is PortraitSprite portraitSprite)
                sprites.Add(portraitSprite);
        }
    }

    public void Animate(float delta)
    {
        foreach(PortraitSprite portraitSprite in sprites)
        {
            if (portraitSprite.AnimationPlayer == null) continue;

            portraitSprite.AnimationPlayer.Advance(delta);
        }

    }

    public void Stop()
    {
        foreach(PortraitSprite portraitSprite in sprites)
        {
            if (portraitSprite.Continuous || portraitSprite.AnimationPlayer == null) continue;

            portraitSprite.AnimationPlayer.Stop();
        }
    }
}
