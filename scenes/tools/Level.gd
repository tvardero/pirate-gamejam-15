class_name Level
extends Node2D

@export var auto_spawn_player: bool = false
@export var auto_spawn_id: int = 0;

var player_packed: PackedScene = preload ("res://scenes/characters/player/Player.tscn");

func _ready():
	if (auto_spawn_player): spawn_player_at(auto_spawn_id);

func spawn_player_at(spawn_id: int, direction: Vector2=Vector2.ZERO) -> void:
	var spawn = find_spawnpoint(spawn_id);
	var spawn_position: Vector2 = spawn.position if spawn else Vector2.ZERO;

	var player = player_packed.instantiate() as Player;
	player.direction = direction;
	player.position = spawn_position;

	add_child(player);

func find_spawnpoint(spawn_id: int) -> SpawnPoint:
	var children = get_children();
	
	for child in children:
		if child is SpawnPoint && child.id == spawn_id:
			return child;

	return null;
