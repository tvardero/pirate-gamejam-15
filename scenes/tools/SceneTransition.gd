@tool

class_name SceneTransition
extends Area2D

var _shape: Shape2D;

@export var destination_level: String;
@export var spawn_id: int;
@export var override_player_direction: bool;
@export var player_direction_override: Vector2;
@export var collision_shape: Shape2D:
	get: return collider.shape if collider else null;
	set(value): _set_shape(value);

@onready var collider: CollisionShape2D = $"CollisionShape2D";

func _ready():
	_set_shape(_shape);

func transit_player(player: Player) -> void:
	var packed_scene = load(destination_level) as PackedScene;
	var direction = player_direction_override if override_player_direction else player.direction;
	WorldState.transit_player_to_scene(packed_scene, spawn_id, direction);

func _set_shape(value: Shape2D):
	_shape = value;
	if collider: collider.shape = value;

func _on_body_entered(body: Node2D):
	if body is Player: transit_player(body);
