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

@onready var all_interactions = [];
@onready var interactLabel=$InteractionComponents/InteractLabel

func _ready():
	update_interactions()

func _physics_process(_delta) -> void:
	var multiplier = sprint_speed if is_sprinting else walk_speed;
	velocity = input_movement_vector * multiplier;
	move_and_collide(velocity);
	_set_animations();
	if Input.is_action_just_pressed("interaction"):
		execute_interaction()

func execute_interaction():
	if all_interactions:
		var cur_interaction = all_interactions[0]
		match cur_interaction.interact_type:
			"start_shake" : print(cur_interaction.interact_value)

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


# Interaction methods

func _on_interaction_area_area_entered(area):
	all_interactions.insert(0, area)
	update_interactions()

func _on_interaction_area_area_exited(area):
	all_interactions.erase(area)
	update_interactions()
	
func update_interactions():
	if all_interactions: #if there are values in this array, then...
		interactLabel.text = all_interactions[0].interact_label
	else:
		interactLabel.text=""

