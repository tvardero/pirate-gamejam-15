using Godot;
using System;
using DialogueManagerRuntime;
using Godot.Collections;
using System.Collections.Generic;
using System.Threading.Tasks;
using SunfallGame.scenes.dialogue.portraits;

public partial class DialogBalloon : CanvasLayer
{    
  [Export] private string nextAction = "ui_accept";
  [Export] private string skipAction = "ui_cancel";

  [Export] private Control balloon;
  [Export] private RichTextLabel characterLabel;
  [Export] private RichTextLabel dialogueLabel;
  [Export] private VBoxContainer responsesMenu;
  [Export] private Control npcPortraitControl;
  [Export] private Control playerPortraitControl;
  [Export] private AudioStreamPlayer talkSoundPlayer;
  [Export] private AudioStream defaultTalkSound;

  private Portrait portrait;
  private Resource resource;
  private Array<Variant> temporaryGameStates = new Array<Variant>();
  private bool isWaitingForInput = false;
  private bool willHideBalloon = false;

  private DialogueLine dialogueLine;
  
  public DialogueLine DialogueLine
  {
    get => dialogueLine;
    set
    {
      SetDialogue(value);
    }
  }

  private string _locale = TranslationServer.GetLocale();

  public override void _Ready()
  {
    balloon.Hide();

    balloon.GuiInput += (@event) =>
    {
      if ((bool)dialogueLabel.Get("is_typing"))
      {
        bool mouseWasClicked = @event is InputEventMouseButton && (@event as InputEventMouseButton).ButtonIndex == MouseButton.Left && @event.IsPressed();
        bool skipButtonWasPressed = @event.IsActionPressed(skipAction);
        if (mouseWasClicked || skipButtonWasPressed)
        {
          GetViewport().SetInputAsHandled();
          dialogueLabel.Call("skip_typing");
          return;
        }
      }

      if (!isWaitingForInput) return;
      if (dialogueLine.Responses.Count > 0) return;

      GetViewport().SetInputAsHandled();

      if (@event is InputEventMouseButton && @event.IsPressed() && (@event as InputEventMouseButton).ButtonIndex == MouseButton.Left)
      {
        Next(dialogueLine.NextId);
      }
      else if (@event.IsActionPressed(nextAction) && GetViewport().GuiGetFocusOwner() == balloon)
      {
        Next(dialogueLine.NextId);
      }
    };

    if (string.IsNullOrEmpty((string)responsesMenu.Get("next_action")))
    {
      responsesMenu.Set("next_action", nextAction);
    }
    responsesMenu.Connect("response_selected", Callable.From((DialogueResponse response) =>
    {
      Next(response.NextId);
    }));

    DialogueManager.Mutated += OnMutated;
  }

  public override void _ExitTree()
  {
    DialogueManager.Mutated -= OnMutated;
  }

  public override void _UnhandledInput(InputEvent @event)
  {
    // Only the balloon is allowed to handle input while it's showing
    GetViewport().SetInputAsHandled();
  }

  public override async void _Notification(int what)
  {
    // Detect a change of locale and update the current dialogue line to show the new language
    if (what == NotificationTranslationChanged)
    {
      float visibleRatio = dialogueLabel.VisibleRatio;
      DialogueLine = await DialogueManager.GetNextDialogueLine(resource, DialogueLine.Id, temporaryGameStates);
      
      if (visibleRatio < 1.0f)
      {
        dialogueLabel.Call("skip_typing");
      }
    }
  }

  public async Task Start(Resource dialogueResource, string title, Array<Variant> extraGameStates = null)
  {
    temporaryGameStates = extraGameStates ?? new Array<Variant>();
    isWaitingForInput = false;
    resource = dialogueResource;

    DialogueLine = await DialogueManager.GetNextDialogueLine(resource, title, temporaryGameStates);
  }

  public async Task Next(string nextId)
  {
    DialogueLine = await DialogueManager.GetNextDialogueLine(resource, nextId, temporaryGameStates);
  }

  #region Helpers
  private async Task SetDialogue(DialogueLine value)
  {
    isWaitingForInput = false;
    balloon.FocusMode = Control.FocusModeEnum.All;
    balloon.GrabFocus();

    if (value == null)
    {
      QueueFree();
      return;
    }

    dialogueLine = value;
    if (!IsNodeReady())
    {
      await ToSignal(this, SignalName.Ready);
    }

    // Set up the character name
    characterLabel.Visible = !string.IsNullOrEmpty(dialogueLine.Character);
    characterLabel.Text = Tr(dialogueLine.Character, "dialogue");

    // Set up the dialogue
    dialogueLabel.Hide();
    dialogueLabel.Set("dialogue_line", dialogueLine);

    // Set up the responses
    responsesMenu.Hide();
    responsesMenu.Set("responses", dialogueLine.Responses);

    // Type out the text
    balloon.Show();
    willHideBalloon = false;

    // Show Portrait
    if (IsInstanceValid(portrait))
        QueueFree();

    if (dialogueLine.Get("char_vars").Obj != null)
    {
        if (dialogueLine.Get("char_vars").Obj is DialogCharVars charVars)
        {
            ShowPortrait(charVars);
        }
    }

    dialogueLabel.Show();
    if (!string.IsNullOrEmpty(dialogueLine.Text))
    {
        dialogueLabel.Call("type_out");
        await ToSignal(dialogueLabel, "finished_typing");
    }

    // Wait for input
    if (dialogueLine.Responses.Count > 0)
    {
        balloon.FocusMode = Control.FocusModeEnum.None;
        responsesMenu.Show();
    }
    else if (!string.IsNullOrEmpty(dialogueLine.Time))
    {
        float time = 0f;
        if (!float.TryParse(dialogueLine.Time, out time))
        {
        time = dialogueLine.Text.Length * 0.02f;
        }
        await ToSignal(GetTree().CreateTimer(time), "timeout");
        Next(dialogueLine.NextId);
    }
    else
    {
        isWaitingForInput = true;
        balloon.FocusMode = Control.FocusModeEnum.All;
        balloon.GrabFocus();
    }
  }
  
  private void ShowPortrait(DialogCharVars charVars)
  {
      if (charVars.Portrait == null) return;
      portrait = charVars.Portrait.Instantiate<Portrait>();

      if (dialogueLine.Get("character").ToString() == "You")
      {
          playerPortraitControl.AddChild(portrait);
      }
      else
      {
          npcPortraitControl.AddChild(portrait);
      }

      if(dialogueLabel.IsConnected("finished_typing", Callable.From(portrait.Stop)))
      {
          dialogueLabel.Disconnect("finished_typing", Callable.From(portrait.Stop));
      }
      
      dialogueLabel.Connect("finished_typing", Callable.From(portrait.Stop));
  }


  #endregion

  #region signals
  private void OnMutated(Dictionary _mutation)
  {
    isWaitingForInput = false;
    willHideBalloon = true;
    GetTree().CreateTimer(0.1f).Timeout += () =>
    {
      if (willHideBalloon)
      {
        willHideBalloon = false;
        balloon.Hide();
      }
    };
  }

  private void OnResponsesMenuResponseSelected(DialogueResponse response)
  {
      Next(response.NextId);
  }

  private void OnDialogLabelSpoke(string letter, int letterIndex, float speed)
  {
      if (letter.Contains(" ") || letter.Contains(".")) return;

      int actualSpeed = (speed >= 1) ? 3 : 1;

      if (letterIndex % actualSpeed != 0) return;

      talkSoundPlayer.Stream = defaultTalkSound;
      talkSoundPlayer.PitchScale = (dialogueLine.Get("character").ToString() == "You") ? 2 : 1;
      talkSoundPlayer.Play();
  }
  #endregion
}
