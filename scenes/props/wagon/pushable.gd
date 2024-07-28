class_name Pushable
extends RigidBody2D

@export var dest: Marker2D
@export var pushable_x: bool = true
@export var pushable_y: bool = true
@export var push_sound: AudioStream

var is_pushed: bool = false
var sound_player: AudioStreamPlayer2D

signal pushed(pos: Vector2)


func _ready():
	lock_rotation = true
	
	find_dest_marker()


func find_dest_marker():
	if !dest:
		# Find a Marker2D to use as destination
		for child in get_children():
			if child is Marker2D:
				dest = child
				break
	
	# Align destination with allowed directions
	if !pushable_x: dest.position.x = position.x
	if !pushable_y: dest.position.y = position.y


func _physics_process(_delta):
	if get_linear_velocity().length() <= 0.01:
		if sound_player:
			sound_player.stream_paused = true


func push(force: Vector2):
	if !pushable_x && !pushable_y: return
	
	if dest:
		# Return if reached destination
		if position.distance_to(dest.position) <= 0.1: return
		
		# Return if moving away from destination
		var target_pos: Vector2 = position + force.normalized()
		if target_pos.distance_to(dest.position) > position.distance_to(dest.position): return
	
	var true_force: Vector2 = Vector2.ZERO
	if pushable_x: true_force.x = force.x
	if pushable_y: true_force.y = force.y
	
	is_pushed = true
	apply_central_force(true_force)
	pushed.emit(position)
	
	if sound_player:
		sound_player.position = global_position
		if sound_player.stream_paused: sound_player.stream_paused = false
		elif !sound_player.playing: play_sound()
		return
	play_sound()


func play_sound():
	sound_player = SoundPlayer.play_sound2D(push_sound, global_position)
