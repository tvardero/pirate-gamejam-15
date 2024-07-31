class_name Level
extends Node2D

@export var lanter_locked: bool = false;

@export_group("Player auto spawn")
@export var auto_spawn_player: bool = true
@export var auto_spawn_id: int = 0;
@export var auto_spawn_direction: Vector2 = Vector2.ZERO;

@export_group("\"Past\" configuration")
@export var past_nodes: Node2D;
@export var past_color: Color;
@export var past_music: AudioStream

@export_group("\"Future\" configuration")
@export var future_nodes: Node2D;
@export var future_color: Color;
@export var future_music: AudioStream

var _player_packed: PackedScene = preload ("res://scenes/characters/player/Player.tscn");
var bg_color: ColorRect;

func _ready():
	if (auto_spawn_player&&!WorldState.player): spawn_player_at(auto_spawn_id, auto_spawn_direction);

	if future_music&&past_music:
		SoundPlayer.play_music(future_music, past_music)

	bg_color = _create_color_rect();
	bg_color.color = future_color if WorldState.in_future else past_color;
	switch_nodes(WorldState.in_future);

func _create_color_rect() -> ColorRect:
	var color_rect = ColorRect.new();
	color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	color_rect.color = Color.TRANSPARENT;

	var canvas = CanvasLayer.new();
	canvas.layer = -1;
	canvas.add_child(color_rect);
	
	add_child(canvas);

	return color_rect;

func spawn_player_at(spawn_id: int, direction: Vector2=Vector2.ZERO) -> void:
	var spawn = find_spawnpoint(spawn_id);
	var spawn_position: Vector2 = spawn.position if spawn else Vector2.ZERO;

	var player = _player_packed.instantiate() as Player;
	player.direction = direction;
	player.position = spawn_position;

	call_deferred("add_child", player);

func find_spawnpoint(spawn_id: int) -> SpawnPoint:
	var children = get_children();
	var first_spawn: SpawnPoint = null;

	for child in children:
		if child is SpawnPoint:
			if !first_spawn: first_spawn = child;
			if child.id == spawn_id: return child;
		
	return first_spawn;

func switch_nodes(to_future: bool):
	past_nodes.visible = !to_future;
	future_nodes.visible = to_future;

func modulate_nodes(val: float):
	val = clamp(val, 0, 1);
	var color = lerp(Color.TRANSPARENT, Color.WHITE, val);
	past_nodes.modulate = color;
	future_nodes.modulate = color;
