extends Node2D

@export var sound: AudioStream
var sound_player: AudioStreamPlayer2D

signal collected


func _ready():
	WorldState.time_changed.connect(_on_time_changed)


func _on_area_2d_body_entered(_body):
	await DialogState.start_from_text('Found a Star Fragment!')
	
	visible = false
	if sound_player: sound_player.stop()
	await WorldState.start_fuse_scene()
	
	collected.emit()
	queue_free()


func _on_time_changed(in_future: bool):
	if in_future && is_visible_in_tree():
		sound_player = SoundPlayer.play_sound2D(sound, global_position)
		sound_player.max_distance = 100
	elif sound_player:
		sound_player.stop()
		sound_player = null
