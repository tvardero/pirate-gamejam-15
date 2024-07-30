extends Node

@onready var audio_players = $AudioPlayers
@onready var audio_players_2D = $AudioPlayers2D
@onready var present_music_player: AudioStreamPlayer = $MusicPlayers/PresentMusicPlayer
@onready var past_music_player: AudioStreamPlayer = $MusicPlayers/PastMusicPlayer
@onready var sfx_present_bus: int = AudioServer.get_bus_index('SFX Present')
@onready var sfx_past_bus: int = AudioServer.get_bus_index('SFX Past')

var music_position: float = 0
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
	AudioServer.set_bus_volume_db(sfx_present_bus, present_db)
	AudioServer.set_bus_volume_db(sfx_past_bus, past_db)

func play_sound(sound: AudioStream, volume: float=0) -> AudioStreamPlayer:
	for audio_player in audio_players.get_children():
		if audio_player.playing: continue ;

		reset_sfx_player(audio_player)
		audio_player.stream = sound
		audio_player.volume_db = volume
		audio_player.play()
		return audio_player

	return null

func play_sound2D(sound: AudioStream, pos: Vector2, volume: float=0) -> AudioStreamPlayer2D:
	for audio_player in audio_players_2D.get_children():
		if audio_player.playing: continue ;
		
		reset_sfx_player(audio_player)
		audio_player.stream = sound
		audio_player.volume_db = volume
		audio_player.position = pos
		audio_player.play()
		return audio_player
		
	return null

func set_time_bus(sound_player, in_future: bool):
	if in_future: sound_player.bus = 'SFX Present'
	else: sound_player.bus = 'SFX Past'


func play_music(present_track, past_track):
	if present_music_player.stream == present_track: return
	
	set_time(WorldState.in_future)
	present_music_player.stream = present_track
	past_music_player.stream = past_track
	present_music_player.play()
	past_music_player.play()


func set_time(in_future: bool, fade_seconds: float = 0):
	if fade_seconds <= 0:
		var present_val: float = 0 if in_future else -80
		var past_val: float = -80 if in_future else 0
		present_music_player.volume_db = present_val
		past_music_player.volume_db = past_val
		AudioServer.set_bus_volume_db(sfx_present_bus, present_val)
		AudioServer.set_bus_volume_db(sfx_past_bus, past_val)
		return
	
	# Calculate fade speed per second, from 0db to -80db
	fade_speed = (1.0 if in_future else -1.0) / fade_seconds;


func pause_music(val: bool):
	if val:
		music_position = present_music_player.get_playback_position()
		present_music_player.stop()
		past_music_player.stop()
	else:
		present_music_player.play(music_position)
		past_music_player.play(music_position)


func reset_sfx_player(sfx_player):
	sfx_player.stop()
	sfx_player.bus = 'SFX'
	sfx_player.pitch_scale = 1
	
	if sfx_player is AudioStreamPlayer2D:
		sfx_player.max_distance = 2000


func stop_all_sfx():
	for audio_player in audio_players.get_children():
		reset_sfx_player(audio_player)
	for audio_player in audio_players_2D.get_children():
		reset_sfx_player(audio_player)
