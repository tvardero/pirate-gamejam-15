extends Node

var in_future: bool = true;

func use_lantern() -> void:
	set_time(!in_future)
	print("todo: lantern, now in future: " + str(in_future))

func set_time(to_future: bool) -> void:
	in_future = to_future;
	SoundPlayer.set_music_track(in_future, 1)

func transit_player_to_scene(destination: PackedScene, spawn_id: int, player_direction: Vector2):
	var level = destination.instantiate();
	if !(level is Level): 
		assert(false, "Invalid destination scene provided, should extend class 'Level'");

	level.spawn_player_at(spawn_id, player_direction);

	var current = get_current_level();
	if current:
		current.visible = false;
		current.queue_free();

	get_tree().root.call_deferred("add_child", level);

func get_current_level() -> Level:
	var children = get_tree().root.get_children();
	for child in children:
		if child is Level: return child;
	
	return null;
