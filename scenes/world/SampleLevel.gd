extends Level

@export var present_music: AudioStream
@export var past_music: AudioStream

func _ready() -> void:	
	super._ready();
	SoundPlayer.play_music(present_music, past_music)
