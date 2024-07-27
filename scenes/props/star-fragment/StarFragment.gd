extends Node2D

@onready var fuse_scene_packed: PackedScene = preload('res://scenes/world/lantern_fuse.tscn')
@export var sound: AudioStream
var sound_player: AudioStreamPlayer2D


func _ready():
	WorldState.time_changed.connect(_on_time_changed)


func _on_area_2d_body_entered(body):
	if !WorldState.in_future: return
	
	await DialogState.start_from_text('Found a Star Fragment!')
	
	visible = false
	sound_player.stop()
	WorldState.disable_movement = true
	var fuse_scene = fuse_scene_packed.instantiate()
	WorldState.get_current_level().add_child(fuse_scene)
	await fuse_scene.tree_exited
	
	WorldState.star_fragment_count += 1
	WorldState.disable_movement = false
	queue_free()


func _on_time_changed(in_future: bool):
	$Area2D.set_deferred('monitoring', in_future)
	if in_future:
		sound_player = SoundPlayer.play_sound2D(sound, global_position)
		sound_player.max_distance = 100
	elif sound_player:
		print('STOPPING')
		sound_player.stop()
		sound_player = null
