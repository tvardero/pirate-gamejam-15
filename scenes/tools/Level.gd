class_name Level
extends Node2D

@export var auto_spawn_player: bool = false
@export var auto_spawn_id: int = 0;
@export var auto_spawn_direction: Vector2 = Vector2.ZERO;
@export var future_music: AudioStream
@export var past_music: AudioStream
@export var past_nodes: Node2D;
@export var future_nodes: Node2D;
var _color_rect: ColorRect;

var player_packed: PackedScene = preload ("res://scenes/characters/player/Player.tscn");

func _ready():
	if (auto_spawn_player&&!WorldState.player_exists): spawn_player_at(auto_spawn_id, auto_spawn_direction);
	if future_music&&past_music:
		SoundPlayer.play_music(future_music, past_music)

	_color_rect = ColorRect.new();
	_color_rect.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)

	var canvas = CanvasLayer.new();
	canvas.layer = -100;
	canvas.add_child(_color_rect);
	
	add_child(canvas);
	move_child(canvas, 0);

	switch_time(WorldState.in_future);

func _process(_delta):
	if Input.is_action_just_pressed('pause'):
		PauseMenu.toggle()

func spawn_player_at(spawn_id: int, direction: Vector2=Vector2.ZERO) -> void:
	var spawn = find_spawnpoint(spawn_id);
	var spawn_position: Vector2 = spawn.position if spawn else Vector2.ZERO;

	var player = player_packed.instantiate() as Player;
	player.direction = direction;
	player.position = spawn_position;

	WorldState.player = player;

	call_deferred("add_child", player);

func find_spawnpoint(spawn_id: int) -> SpawnPoint:
	var children = get_children();
	
	for child in children:
		if child is SpawnPoint&&child.id == spawn_id: return child;

	return null;

func switch_time(to_future: bool):
	_color_rect.color = Color.BLACK if to_future else Color.WHITE;
	past_nodes.visible = !to_future;
	future_nodes.visible = to_future;
