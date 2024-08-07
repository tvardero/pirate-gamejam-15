class_name PlayerInputController
extends Node

@export var disable_movement: bool = false;
var player: Player;

var _is_disabled: bool:
	get: return disable_movement||WorldState.disable_movement||DialogState.balloon;

func _ready():
	player = get_parent() as Player;

# process keyboard/mouse/gamepad inputs
func _unhandled_input(event: InputEvent) -> void:
	if _is_disabled: return
	
	var handled: bool = false;
	
	handled = handled||process_movement_input_events(event);
	handled = handled||process_lantern_input_event(event);
	handled = handled||process_interaction_input_event(event);
	handled = handled||process_sprint_input_event(event);

	# set event as handled, so other scenes will not recieve the same event
	if (handled): get_tree().root.set_input_as_handled();

func _physics_process(_delta) -> void:
	if _is_disabled:
		player.input_movement_vector = Vector2.ZERO;
		return
	
	var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down", 0.1);
	player.input_movement_vector = input_vector.normalized();

func process_movement_input_events(event: InputEvent) -> bool:
	var movement_action_names = ["move_down", "move_up", "move_left", "move_right"];
	return movement_action_names.any(func(action_name): event.is_action(action_name));

func process_lantern_input_event(event: InputEvent) -> bool:
	if !event.is_action("lantern"): return false;
	if !event.is_echo() && event.is_pressed() && WorldState.lantern_unlocked:
		player.try_use_lantern();
	return true;

func process_interaction_input_event(event: InputEvent) -> bool:
	if !event.is_action("interaction"): return false;
	if !event.is_echo()&&event.is_pressed(): player.try_interact();
	return true;

func process_sprint_input_event(event: InputEvent) -> bool:
	if !event.is_action("sprint"): return false;
	player.is_sprinting = event.is_pressed();
	return true;
