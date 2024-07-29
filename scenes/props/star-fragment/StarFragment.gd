extends Node2D

@export var sound: AudioStream
var sound_player: AudioStreamPlayer2D

signal collected

func _on_area_2d_body_entered(_body):
	await DialogState.start_from_text('Found a Star Fragment!')
	
	visible = false
	if sound_player: sound_player.stop()
	await WorldState.start_fuse_scene()
	
	collected.emit()
	queue_free()