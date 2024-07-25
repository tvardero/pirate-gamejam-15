extends Node2D

@onready var fuse_scene_packed: PackedScene = preload('res://scenes/world/lantern_fuse.tscn')


func _on_interactable_interacted(_initiator: Node):
	visible = false
	await DialogState.start_from_text('Found a Star Fragment!')
	
	var fuse_scene = fuse_scene_packed.instantiate()
	WorldState.get_current_level().add_child(fuse_scene)
	await fuse_scene.tree_exited
	
	WorldState.star_fragment_count += 1
	queue_free()
