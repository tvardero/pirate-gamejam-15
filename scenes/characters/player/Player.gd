class_name Player
extends CharacterBody2D

var input_movement_vector: Vector2 = Vector2.ZERO;
var is_sprinting: bool = false;

@export var walk_speed: float = 5;

@export var sprint_speed: float = 12;

var _sprint_to_walk_ratio:
	get: return sprint_speed / walk_speed;

@onready var _animation_tree: AnimationTree = $"AnimationTree";
@onready var _animation_player: AnimationPlayer = $"AnimationPlayer";

func _physics_process(_delta) -> void:
	var multiplier = sprint_speed if is_sprinting else walk_speed;
	velocity = input_movement_vector * multiplier;
	move_and_collide(velocity);
	_set_animations();

func try_interact() -> bool:
	print("todo: interaction")
	return false;

func _set_animations():
	var is_walking = input_movement_vector != Vector2.ZERO;
	_animation_tree["parameters/conditions/is_idle"] = !is_walking;
	_animation_tree["parameters/conditions/is_walking"] = is_walking;

	_animation_player.speed_scale = 1 if !is_walking||!is_sprinting else _sprint_to_walk_ratio;

	# preserve old blend position when player stopped
	if !is_walking: return ;
	
	var x = input_movement_vector.x;
	_animation_tree["parameters/idle/blend_position"] = x;
	_animation_tree["parameters/walking/blend_position"] = x;
