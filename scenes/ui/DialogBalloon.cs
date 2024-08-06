using Godot;
using System;
using DialogueManagerRuntime;

public partial class DialogBalloon : CanvasLayer
{    
    [Export] private string nextAction;
    [Export] private string skipAction;

    [Export] private Control balloon;
    [Export] private RichTextLabel characterLabel;
    [Export] private RichTextLabel dialogueLabel;
    [Export] private Node responsesMenu;
    [Export] private Control npcPortraitControl;
    [Export] private Control playerPortraitControl;
    [Export] private AudioStreamPlayer talk_sound_player;
    [Export] private AudioStream default_talk_sound;

    private Portrait portrait;

}
