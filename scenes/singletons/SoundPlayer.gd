extends Node

@onready var audio_players = $AudioPlayers
@onready var audio_players_2D = $AudioPlayers2D
@onready var present_music_player: AudioStreamPlayer = $MusicPlayers/PresentMusicPlayer
@onready var past_music_player: AudioStreamPlayer = $MusicPlayers/PastMusicPlayer

var fade_speed: float = 0

func _physics_process(delta):
	if fade_speed == 0: return ;

	var inc = fade_speed * delta
	
	# Convert linear progress to decibels
	var present_prog = clamp(db_to_linear(present_music_player.volume_db) + inc, 0, 1)
	var present_db = clamp(linear_to_db(present_prog), -80, 0)
	
	var past_prog = clamp(db_to_linear(past_music_player.volume_db) - inc, 0, 1)
	var past_db = clamp(linear_to_db(past_prog), -80, 0)

	present_music_player.volume_db = present_db
	past_music_player.volume_db = past_db

func play_sound(sound: AudioStream, volume: float=0) -> AudioStreamPlayer:
	for audio_player in audio_players.get_children():
		if audio_player.playing: continue ;

		audio_player.stream = sound
		audio_player.volume_db = volume
		audio_player.pitch_scale = 1
		audio_player.play()
		return audio_player

	return null

func play_sound2D(sound: AudioStream, pos: Vector2, volume: float=0) -> AudioStreamPlayer2D:
	for audio_player in audio_players_2D.get_children():
		if audio_player.playing: continue ;
		
		audio_player.stream = sound
		audio_player.volume_db = volume
		audio_player.pitch_scale = 1
		audio_player.position = pos
		audio_player.play()
		return audio_player
		
	return null

func play_music(present_track, past_track):
	if present_music_player.stream == present_track: return
	
	set_music_track(WorldState.in_future)
	present_music_player.stream = present_track
	past_music_player.stream = past_track
	present_music_player.play()
	past_music_player.play()

func set_music_track(future: bool, fade_seconds: float=0):
	if fade_seconds <= 0:
		present_music_player.volume_db = 0 if future else - 80;
		past_music_player.volume_db = -80 if future else 0;
		return ;

	# Calculate fade speed per second, from 0db to -80db
	fade_speed = (1.0 if future else -1.0) / fade_seconds;
