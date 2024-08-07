using Godot;
using System;
using DialogueManagerRuntime;
using Godot.Collections;

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

    // public override void _Ready()
    // {
    //     balloon.Hide();
    //     DialogueManager.Mutated += DialogueManager_Mutated;
        
    //     // If the responses menu doesn't have a next action set, use this one
    //     if (responsesMenu.Get("next_action").ToString() == string.Empty)
    //     {
    //         responsesMenu.Set("next_action", next_action);
    //     }
    // }

    // private void DialogueManager_Mutated(Dictionary mutation)
    // {
	// is_waiting_for_input = false
	// will_hide_balloon = true
	// get_tree().create_timer(0.1).timeout.connect(func():
	// 	if will_hide_balloon:
	// 		will_hide_balloon = false
	// 		balloon.hide()
	// )
    // }

}
