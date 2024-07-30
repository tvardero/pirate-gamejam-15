extends Level

@export var first_visit: bool = true
var dialog_resource: DialogueResource = preload('res://scenes/dialogue/Bridge.dialogue')
var river_sfx_1 = preload('res://assets/sounds/river/river-3.mp3')
var river_sfx_2 = preload('res://assets/sounds/river/waterfall.mp3')
var sound_player_1
var sound_player_2


func _ready():
	super()
	
	if WorldState.in_future: trigger_dialog(true)
	else: WorldState.time_changed.connect(trigger_dialog)

	var star_fragment = get_node_or_null("Future/StarFragment")
	if star_fragment: 
		star_fragment.collected.connect(_on_collected)
	
	var sound_player_1 = SoundPlayer.play_sound2D(river_sfx_1, $WaterfallAudio.global_position, -1)
	sound_player_1.max_distance = 200
	sound_player_1.pitch_scale = 0.58
	var sound_player_2 = SoundPlayer.play_sound2D(river_sfx_2, $WaterfallAudio.global_position, 0)
	sound_player_2.max_distance = 300
	sound_player_2.pitch_scale = 0.58


func trigger_dialog(_in_future: bool):
	if !first_visit: return
	DialogState.start_dialog(dialog_resource, 'enter_bridge_scene_first_time')
	first_visit = false


func _on_collected():
	DialogState.start_dialog(dialog_resource, 'after_fusing_first_star_fragment')