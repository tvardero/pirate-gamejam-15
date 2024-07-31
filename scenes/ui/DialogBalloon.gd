class_name DialogBalloon
extends CanvasLayer

## The action to use for advancing the dialogue
@export var next_action: StringName = &"ui_accept"

## The action to use to skip typing the dialogue
@export var skip_action: StringName = &"ui_cancel"

@onready var balloon: Control = %Balloon
@onready var character_label: RichTextLabel = %CharacterLabel
@onready var dialogue_label: DialogueLabel = %DialogueLabel
@onready var responses_menu: DialogueResponsesMenu = %ResponsesMenu

@onready var portrait_sprite: Sprite2D = $Balloon/Portrait/Sprite2D
var current_sprites: Array[Sprite2D] = []
@onready var talk_sound_player: AudioStreamPlayer = $TalkSound
@onready var default_talk_sound: AudioStream = preload('res://assets/sounds/ui/menu_beep.wav')

## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

var _locale: String = TranslationServer.get_locale()

## The current line
var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		is_waiting_for_input = false
		balloon.focus_mode = Control.FOCUS_ALL
		balloon.grab_focus()

		# The dialogue has finished so close the balloon
		if not next_dialogue_line:
			queue_free()
			return

		# If the node isn't ready yet then none of the labels will be ready yet either
		if not is_node_ready():
			await ready

		dialogue_line = next_dialogue_line

		character_label.visible = not dialogue_line.character.is_empty()
		character_label.text = tr(dialogue_line.character, "dialogue")

		dialogue_label.hide()
		dialogue_label.dialogue_line = dialogue_line

		responses_menu.hide()
		responses_menu.set_responses(dialogue_line.responses)

		# Show our balloon
		balloon.show()
		will_hide_balloon = false

		# Show portraits
		for sprite in current_sprites:
			sprite.queue_free()
		current_sprites = []
		
		if dialogue_line.char_vars:
			show_portrait(dialogue_line.char_vars)
		
		dialogue_label.show()
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing

		# Wait for input
		if dialogue_line.responses.size() > 0:
			balloon.focus_mode = Control.FOCUS_NONE
			responses_menu.show()
		elif dialogue_line.time != "":
			var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)
		else:
			is_waiting_for_input = true
			balloon.focus_mode = Control.FOCUS_ALL
			balloon.grab_focus()
	get:
		return dialogue_line


func _ready() -> void:
	_on_sprite_texture_changed()
	balloon.hide()
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)

	# If the responses menu doesn't have a next action set, use this one
	if responses_menu.next_action.is_empty():
		responses_menu.next_action = next_action


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


func _process(delta):
	animate_portraits(delta)


func _notification(what: int) -> void:
	## Detect a change of locale and update the current dialogue line to show the new language
	if what == NOTIFICATION_TRANSLATION_CHANGED and _locale != TranslationServer.get_locale() and is_instance_valid(dialogue_label):
		_locale = TranslationServer.get_locale()
		var visible_ratio = dialogue_label.visible_ratio
		self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.id)
		if visible_ratio < 1:
			dialogue_label.skip_typing()


## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	temporary_game_states =  [self] + extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)


## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)


func show_portrait(char_vars: DialogCharVars):
	for sheet in char_vars.spritesheets:
		var sprite: Sprite2D = portrait_sprite.duplicate()
		var ap: AnimationPlayer = sprite.get_node('AnimationPlayer')
		var anim_lib: AnimationLibrary = AnimationLibrary.new()
		var anim: Animation = Animation.new()
		
		anim.length = sheet.frame_count / sheet.framerate
		#anim.loop_mode = Animation.LOOP_LINEAR
		sprite.texture = sheet.spritesheet
		sprite.hframes = sheet.h_frames
		sprite.vframes = sheet.v_frames
		
		current_sprites.append(sprite)
		sprite.show()
		portrait_sprite.add_sibling(sprite)
		
		var ap_root_node: Node = ap.get_node(ap.root_node)
		var sprite_path: NodePath = ap_root_node.get_path_to(sprite)
		var sprite_frame_path: NodePath = "%s:frame" % sprite_path
		var frame_track_id: int = anim.add_track(Animation.TYPE_VALUE)
		anim.track_set_path(frame_track_id, sprite_frame_path)
		
		for frame_index in sheet.frame_count:
			var time: float = float(frame_index) / float(sheet.frame_count) * anim.length
			anim.track_insert_key(frame_track_id, time, frame_index)
		
		sheet.curr_ap = ap
		anim_lib.add_animation('Portrait', anim)
		ap.add_animation_library('Animations', anim_lib)
		#ap.play('Animations/Portrait')
		ap.assigned_animation = 'Animations/Portrait'
		
		ap.animation_finished.connect(func(_anim): ap.seek(0))
	if dialogue_label.finished_typing.is_connected(stop_portraits): dialogue_label.finished_typing.disconnect(stop_portraits)
	dialogue_label.finished_typing.connect(stop_portraits)


func animate_portraits(delta: float):
	if !dialogue_line.char_vars: return
	
	for sheet in dialogue_line.char_vars.spritesheets:
		if !sheet.curr_ap: continue
		sheet.curr_ap.advance(delta)


func stop_portraits():
	if !dialogue_line.char_vars: return
	
	for sheet in dialogue_line.char_vars.spritesheets:
		if !sheet.curr_ap: continue
		if sheet.continuous: continue
		sheet.curr_ap.stop()


#region Signals


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	get_tree().create_timer(0.1).timeout.connect(func():
		if will_hide_balloon:
			will_hide_balloon = false
			balloon.hide()
	)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# See if we need to skip typing of the dialogue
	if dialogue_label.is_typing:
		var mouse_was_clicked: bool = event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.is_pressed()
		var skip_button_was_pressed: bool = event.is_action_pressed(skip_action)
		if mouse_was_clicked or skip_button_was_pressed:
			get_viewport().set_input_as_handled()
			dialogue_label.skip_typing()
			return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return

	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed(next_action) and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)


func _on_responses_menu_response_selected(response: DialogueResponse) -> void:
	next(response.next_id)


func _on_dialogue_label_spoke(letter: String, letter_index: int, speed: float):
	if letter in [" ", "."]: return
	
	var actual_speed: int = 3 if speed >= 1 else 2
	if letter_index % actual_speed != 0: return
	
	talk_sound_player.stream = default_talk_sound
	talk_sound_player.pitch_scale = 2 if dialogue_line.character == 'You' else 1
	talk_sound_player.play()


func _on_sprite_texture_changed():
	portrait_sprite.offset.y = -portrait_sprite.texture.get_height()

#endregion
