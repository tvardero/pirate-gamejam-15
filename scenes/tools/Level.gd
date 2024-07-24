class_name Level
extends Node2D

@export var auto_spawn_player: bool = false
@export var auto_spawn_id: int = 0;
@export var auto_spawn_direction: Vector2 = Vector2.ZERO;

@export var present_music: AudioStream
@export var past_music: AudioStream

var player_packed: PackedScene = preload ("res://scenes/characters/player/Player.tscn");

func _ready():
	if (auto_spawn_player&&!WorldState.player_exists): spawn_player_at(auto_spawn_id, auto_spawn_direction);
	if present_music&&past_music:
		SoundPlayer.play_music(present_music, past_music)

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

func switch_time(_to_future: bool):
	print("Switching time is not implemented for this level: " + str(name));