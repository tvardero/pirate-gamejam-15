extends StaticBody2D


@onready var sfx: AudioStream = preload('res://assets/sounds/star-fragment-hum/star-fragment-hum-1.mp3')

func _ready():
	var sound_player = SoundPlayer.play_sound2D(sfx, global_position)
	sound_player.max_distance = 150
	SoundPlayer.set_time_bus(sound_player, false)

func _on_interactable_interacted(initiator):
	if initiator is Node2D:
		if WorldState.in_future:
			DialogState.start_dialog(load('res://scenes/dialogue/Clubhouse.dialogue'), 'try_clubhouse_future')
		else:
			if !WorldState.got_fuse_from_clubhouse:
				if !WorldState.password_found:
					DialogState.start_dialog(load('res://scenes/dialogue/Clubhouse.dialogue'), 'try_clubhouse_past')
				else:
					DialogState.start_dialog(load('res://scenes/dialogue/Clubhouse.dialogue'), 'clubhouse_past_with_password')
