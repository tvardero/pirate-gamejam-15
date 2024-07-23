extends StaticBody2D

@onready var sfx: AudioStream = preload('res://assets/sounds/star-fragment-hum/star-fragment-hum-1.mp3')


func _ready():
	var sound_player = SoundPlayer.play_sound2D(sfx, position)
	sound_player.max_distance = 300


func _on_interactable_interacted(_initiator):
	DialogState.start_dialog(load('res://scenes/dialogue/Test.dialogue'))
