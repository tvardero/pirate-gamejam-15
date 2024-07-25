class_name Pushable
extends RigidBody2D

@onready var start_pos: Vector2 = position
@export var pushable_x: bool = true
@export var pushable_y: bool = true
@export var max_distance: float = 50
@export var push_sound: AudioStream

var is_pushed: bool = false
var sound_player: AudioStreamPlayer2D


func _physics_process(_delta):
	if get_linear_velocity().length() <= 0.01:
		if sound_player:
			sound_player.stream_paused = true


func push(force: Vector2):
	if position.distance_to(start_pos) >= max_distance: return
	
	var true_force: Vector2 = Vector2.ZERO
	if pushable_x: true_force.x = force.x
	if pushable_y: true_force.y = force.y
	
	is_pushed = true
	apply_central_force(true_force)
	
	if sound_player:
		sound_player.position = global_position
		if sound_player.stream_paused: sound_player.stream_paused = false
		elif !sound_player.playing: play_sound()
		return
	play_sound()


func play_sound():
	sound_player = SoundPlayer.play_sound2D(push_sound, global_position)
