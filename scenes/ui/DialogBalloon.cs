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
    [Export] private VBoxContainer responsesMenu;
    [Export] private Control npcPortraitControl;
    [Export] private Control playerPortraitControl;
    [Export] private AudioStreamPlayer talk_sound_player;
    [Export] private AudioStream default_talk_sound;

    private Portrait portrait;
    private Resource dialogueResource;
    private Godot.Collections.Array temporary_game_states;

    // See if we are waiting for the player
    private bool is_waiting_for_input = false;

    // See if we are running a long mutation and should hide the balloon
    private bool will_hide_balloon = false;

    private string _locale = TranslationServer.GetLocale();

    private DialogueLine _dialogueLine;

    private DialogueLine dialogueLine {
        get { return _dialogueLine;}
        set {
            is_waiting_for_input = false;

            balloon.FocusMode = Control.FocusModeEnum.All;
            balloon.GrabFocus();

            // The dialogue has finished so close the balloon
            if (value == null)
            {
                QueueFree();
                return;
            }

            // If the node isn't ready yet then none of the labels will be ready yet either
            if (!IsNodeReady())
            {
                WaitForReady();
            }

            _dialogueLine = value;

            characterLabel.Visible = !(dialogueLine.Get("character").ToString() == string.Empty);
            characterLabel.Text = Tr(dialogueLine.Get("character").ToString(), "dialogue");

            characterLabel.Hide();
		    characterLabel.Set("dialogueLine", dialogueLine);

		    responsesMenu.Hide();
            responsesMenu.Set("responses", dialogueLine.Responses);		    

            // Show our balloon
            balloon.Show();
            will_hide_balloon = false;

            // Show portrait
            if (GodotObject.IsInstanceValid(portrait)) portrait.QueueFree();

            // if (dialogueLine.Get("char_vars").Obj != null)
            //     show_portrait(dialogue_line.char_vars)
            
            // dialogue_label.show()
            // if not dialogue_line.text.is_empty():
            //     dialogue_label.type_out()
            //     await dialogue_label.finished_typing

            // # Wait for input
            // if dialogue_line.responses.size() > 0:
            //     balloon.focus_mode = Control.FOCUS_NONE
            //     responses_menu.show()
            // elif dialogue_line.time != "":
            //     var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
            //     await get_tree().create_timer(time).timeout
            //     next(dialogue_line.next_id)
            // else:
            //     is_waiting_for_input = true
            //     balloon.focus_mode = Control.FOCUS_ALL
            //     balloon.grab_focus()
        }
    }
    
    private void ShowPortrait(Resource charVars)
    {
        if (charVars.Get("portrait").Obj == null) return;

    //     	portrait = (charVars.Get("portrait") as PackedScene).Instantiate();
	// if dialogue_line.character == 'You':
	// 	player_portrait_control.add_child(portrait)
	// else: npc_portrait_control.add_child(portrait)
	
	// if dialogue_label.finished_typing.is_connected(portrait.stop): dialogue_label.finished_typing.disconnect(portrait.stop)
	// dialogue_label.finished_typing.connect(portrait.stop)

    }

	


    private async void WaitForReady()
    {
        await ToSignal(GetParent(), SignalName.Ready);
    }
}
