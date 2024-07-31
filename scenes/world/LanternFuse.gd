extends CanvasLayer

@onready var build_sfx = preload('res://assets/sounds/lantern/fuse-build.wav')
@onready var woosh_sfx = preload('res://assets/sounds/lantern/fuse-woosh.wav')

@export var rest_location: Node2D;
@export var destination_location: Node2D;
@export var destination_radius: float = 15;
@export var keyboard_input_speed: float = 35;

@onready var shard: Node2D = $"MarginContainer/Fragment"
@onready var anim = $"MarginContainer/Control/AnimatedSprite2D"

var is_grabbed: bool = false;
var is_grabbed_by_mouse: bool = false;
var reached_destination: bool = false;

signal finished

func _ready():
	WorldState.disable_movement = true;

func _physics_process(delta):
	if reached_destination || (shard.position - destination_location.position).length() < destination_radius:
		is_grabbed = false;
		reached_destination = true;

		shard.position = shard.position.lerp(destination_location.position, 5 * delta)
		if (shard.position - destination_location.position).length() < 0.25:
			shard.position = destination_location.position;
			resolve();

		return ;

	if is_grabbed:
		shard.position = lerp(shard.position, get_tree().root.get_mouse_position(), 10 * delta)
	else:
		var input_vector = Input.get_vector("move_left", "move_right", "move_up", "move_down");
		if input_vector == Vector2.ZERO: 
			shard.position = lerp(shard.position, rest_location.position, 10 * delta)
		else: 
			shard.position += delta * input_vector * keyboard_input_speed;
	
func _input(event):
	var kb_action_names = ["move_left", "move_right", "move_up", "move_down"];
	var handled = false;

	if reached_destination:
		handled = true;

	elif event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			is_grabbed = event.pressed;
			handled = true;
		
	elif kb_action_names.any(func(_name): event.is_action(_name)):
		is_grabbed = false;
		handled = true;
	
	if handled: get_tree().root.set_input_as_handled();
	
func resolve():
	anim.play('play')
	SoundPlayer.play_sound(build_sfx)

	await get_tree().create_timer(0.4).timeout
	SoundPlayer.play_sound(woosh_sfx)

	await get_tree().create_timer(0.4).timeout
	shard.visible = false

	await get_tree().create_timer(1.0).timeout
	WorldState.star_fragment_count += 1;
	WorldState.disable_movement = false;
	finished.emit()
	queue_free()
