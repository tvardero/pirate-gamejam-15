using Godot;
using System;

public partial class SceneTransitionVisual : CanvasLayer
{
    [Signal]
    public delegate void FinishedEventHandler();

    [Signal]
    public delegate void HalfwayEventHandler();

    [Export]
    private float AnimationLength = 1.0f;

    [Export]
    private Curve AnimationCurve;

    [Export]
    private ColorRect ColorRect;

    private float _animationLength;
    private float _time = 0;

    public override void _Ready()
    {
        Stop();
    }

    public override void _Process(double delta)
    {
        if (!Visible) return;
        
        if (_time >= _animationLength)
        {
            Stop();
            return;
        }
        
        if (_time >= _animationLength / 2)
        {
            EmitSignal(SignalName.Halfway);
        }
	
        float prog = _time / _animationLength;
        
        ColorRect.Color = new Color(ColorRect.Color.R, ColorRect.Color.G, ColorRect.Color.B,  AnimationCurve.Sample(prog));
    
        _time += (float)delta;
    }

    private void Start(float length = Mathf.Inf)
    {
        if (length == Mathf.Inf) length = AnimationLength;
        
        ColorRect.Color = (WorldState.Instance.InFuture) ? Colors.Black : Colors.White;
        _animationLength = length;
        _time = 0;
        Visible = true;
    }

    private void Stop()
    {
        Visible = false;
        EmitSignal(SignalName.Finished);
    }
}
