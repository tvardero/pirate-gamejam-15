using DialogueManagerRuntime;
using Godot;
using System;

public partial class DialogState : Node
{
    public static DialogState Instance { get; private set; }
    
    [Export]
    private PackedScene balloonPacked;

    private DialogueManager _dialogueManager;

    public override void _Ready()
    {
        Instance = this;

        _dialogueManager = DialogueManager.Instance as DialogueManager;
    } 
}
