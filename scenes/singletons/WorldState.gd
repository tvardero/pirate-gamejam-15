extends Node

var lantern_unlocked: bool = false;
var in_future: bool = true;
var star_fragment_count: int = 0
var disable_movement: bool = false;
var player: Player = null;
var player_exists: bool:
	get: return player != null;
signal time_changed(to_future)

var scene_transition_visual_packed: PackedScene = preload('res://scenes/ui/SceneTransitionVisual.tscn')
var scene_transition_visual
var fuse_scene_packed: PackedScene = preload('res://scenes/world/lantern_fuse.tscn')

var policeman_moved: bool = false
var town1_gate_open: bool = false
var newspaper_picked_up: bool = false
var password_found: bool = false
var sewage_valve_off: bool = false

var saved_level_states: Dictionary = {}

func _ready():
	scene_transition_visual = scene_transition_visual_packed.instantiate()
	add_child(scene_transition_visual)

func use_lantern() -> bool:
	if !lantern_unlocked: return false;

	var will_be_set_to_future = !in_future;

	var p = get_player();
	if !p: return true;

	var collided = p.detect_collision_before_time_switch(will_be_set_to_future);
	if collided: return false;

	set_time(!in_future)
	return true;

func set_time(to_future: bool) -> void:
	in_future = to_future;
	SoundPlayer.set_music_track(in_future, 1)
	var level = get_current_level();
	if level: level.switch_time(to_future)
	time_changed.emit(to_future)
	
	var p = get_player();
	if !p: return ;
	
	p.set_collision_layer_value(1, !to_future)
	p.set_collision_mask_value(1, !to_future)
	p.set_collision_layer_value(2, to_future)
	p.set_collision_mask_value(2, to_future)

func transit_player_to_scene(destination: PackedScene, spawn_id: int, player_direction: Vector2):
	disable_movement = true
	DialogState.disabled = true
	scene_transition_visual.start()
	
	var level = load_level_state(destination);
	if !(level is Level):
		assert(false, "Invalid destination scene provided, should extend class 'Level'");
	
	await scene_transition_visual.halfway
	
	var current = get_current_level();
	if current:
		save_level_state(current)
		current.visible = false;
		current.queue_free();
	
	level.spawn_player_at(spawn_id, player_direction);
	get_tree().root.call_deferred("add_child", level);
	
	await scene_transition_visual.finished
	
	disable_movement = false
	DialogState.disabled = false

func get_current_level() -> Level:
	var children = get_tree().root.get_children();
	for child in children:
		if child is Level && !child.is_queued_for_deletion() && child.visible: return child;
	
	return null;

func get_player() -> Player:
	var level = get_current_level();
	if !level: return null;

	for child in level.get_children():
		if child is Player: return child;
	
	return null;

func save_level_state(level: Level):
	var packed_level = PackedScene.new()
	packed_level.pack(level)
	saved_level_states[level.name] = packed_level

func load_level_state(packed_level: PackedScene) -> Level:
	var level: Level = packed_level.instantiate()
	
	if saved_level_states.has(level.name):
		level.queue_free()
		var saved_level = saved_level_states[level.name].instantiate()
		for child in saved_level.get_children():
			if child is SceneTransition: 
				for conn in child.get_signal_connection_list('body_entered'):
					child.disconnect(conn.signal, conn.callable)
		return saved_level
	return level

func start_fuse_scene():
	if DialogState.balloon: DialogState.balloon.queue_free()
	
	disable_movement = true
	var fuse_scene = fuse_scene_packed.instantiate()
	get_current_level().add_child(fuse_scene)
	await fuse_scene.tree_exited
	
	star_fragment_count += 1
	disable_movement = false
