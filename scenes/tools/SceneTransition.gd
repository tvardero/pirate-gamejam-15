@tool

class_name SceneTransition
extends Area2D

@export var destination_level: String;
@export var spawn_id: int;
@export var override_player_direction: bool;
@export var player_direction_override: Vector2;

@onready var collider: CollisionShape2D = $CollisionShape2D;

func _ready():
	body_entered.connect(_on_body_entered)

func transit_player(player: Player) -> void:
	var packed_scene = load(destination_level) as PackedScene;
	var direction = player_direction_override if override_player_direction else player.direction;
	WorldState.transit_player_to_scene(packed_scene, spawn_id, direction);

func _on_body_entered(body: Node2D):
	if body is Player: transit_player(body);
