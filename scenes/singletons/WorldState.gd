extends Node

var lantern_unlocked: bool = false;
var in_future: bool = true;
var disable_movement: bool = false;
var player: Player = null;
var player_exists: bool:
	get: return player != null;
	
var policeman_moved: bool = false
var town1_gate_open: bool = false
var newspaper_picked_up: bool = false
var password_found: bool = false

func use_lantern() -> bool:
	if !lantern_unlocked: return false;
	set_time(!in_future)
	print("todo: lantern, now in future: " + str(in_future))
	return true;

func set_time(to_future: bool) -> void:
	in_future = to_future;
	SoundPlayer.set_music_track(in_future, 1)
	var level = get_current_level();
	if level: level.switch_time(to_future)

	var p = get_player();
	if !p: return ;
	
	p.set_collision_layer_value(1, !to_future)
	p.set_collision_mask_value(1, !to_future)
	p.set_collision_layer_value(2, to_future)
	p.set_collision_mask_value(2, to_future)

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

func get_player() -> Player:
	var level = get_current_level();
	if !level: return null;

	for child in level.get_children():
		if child is Player: return child;
	
	return null;
