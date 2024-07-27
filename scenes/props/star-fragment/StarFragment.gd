extends Node2D

@onready var fuse_scene_packed: PackedScene = preload('res://scenes/world/lantern_fuse.tscn')
@export var sound: AudioStream
var sound_player


func _ready():
	sound_player = SoundPlayer.play_sound2D(sound, position)
	sound_player.max_distance = 100


func _on_area_2d_body_entered(body):
	visible = false
	sound_player.stop()
	
	await DialogState.start_from_text('Found a Star Fragment!')
	
	WorldState.disable_movement = true
	var fuse_scene = fuse_scene_packed.instantiate()
	WorldState.get_current_level().add_child(fuse_scene)
	await fuse_scene.tree_exited
	
	WorldState.star_fragment_count += 1
	WorldState.disable_movement = false
	queue_free()
