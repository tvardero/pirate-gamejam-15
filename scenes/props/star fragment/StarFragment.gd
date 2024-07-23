extends StaticBody2D

@onready var sfx: AudioStream = preload('res://assets/sounds/star-fragment-hum/star-fragment-hum-1.mp3')


func _ready():
	var sound_player = SoundPlayer.play_sound2D(sfx, position)
	sound_player.max_distance = 300
