extends Node2D

@export var present_music: AudioStream
@export var past_music: AudioStream


func _ready() -> void:
	print("Hello!")
	
	SoundPlayer.play_music(present_music, past_music)
