class_name Player
extends CharacterBody2D

var input_movement_vector: Vector2 = Vector2.ZERO;
var is_sprinting: bool = false;
var _direction: Vector2 = Vector2.ZERO;

@export var walk_speed: float = 3;
@export var sprint_speed: float = 5;
@onready var _interaction_area: Area2D = $"InteractionArea";
@onready var _animation_tree: AnimationTree = $"AnimationTree";
@onready var _animation_player: AnimationPlayer = $"AnimationPlayer";

var direction: Vector2:
	get: return _direction;
	set(value): _set_direction(value);

var _sprint_to_walk_ratio: float:
	get: return sprint_speed / walk_speed;

func use_lantern():
	var success = WorldState.use_lantern();
	if success:	_animation_tree["parameters/conditions/lantern"] = true;

func _physics_process(_delta) -> void:
	var multiplier = sprint_speed if is_sprinting else walk_speed;
	velocity = input_movement_vector * multiplier;
	move_and_collide(velocity);
	_set_animations();

func _ready():
	_set_direction(_direction);

func try_interact() -> Node2D:
	var _sort_interactables_by_dist = func(a: Interactable, b: Interactable) -> bool:
		var lensq_a = (a.position - position).length_squared();
		var lensq_b = (b.position - position).length_squared();
		return lensq_a <= lensq_b;

	var areas = _interaction_area.get_overlapping_areas();
	if len(areas) == 0:
		return null;

	var interactables := areas.map(func(area): return area.get_parent()).filter(func(i): return i != null&&i is Interactable);
	interactables.sort_custom(_sort_interactables_by_dist);
	
	var closest_interactable = interactables[0] as Interactable;
	closest_interactable.interact(self);
	return closest_interactable.get_parent();

func _set_animations():
	var is_walking = input_movement_vector != Vector2.ZERO;
	_animation_tree["parameters/conditions/is_idle"] = !is_walking;
	_animation_tree["parameters/conditions/is_walking"] = is_walking;

	_animation_player.speed_scale = 1.0 if !is_walking||!is_sprinting else _sprint_to_walk_ratio;

	# preserve old blend position when player stopped
	if !is_walking: return ;
	_set_direction(input_movement_vector);

func _set_direction(value: Vector2):
	_direction = value;

	if !_animation_tree: return ;
	_animation_tree["parameters/idle/blend_position"] = _direction;
	_animation_tree["parameters/walk/blend_position"] = _direction;
	_animation_tree["parameters/lantern/blend_position"] = _direction.x;
