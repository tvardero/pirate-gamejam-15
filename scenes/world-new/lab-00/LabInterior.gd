extends Level

@export var NOISE_SHAKE_SPEED: float = 30.0
@export var NOISE_SWAY_SPEED: float = 1.0
@export var NOISE_SHAKE_STRENGTH: float = 60.0
@export var NOISE_SWAY_STRENGTH: float = 10.0
@export var RANDOM_SHAKE_STRENGTH: float = 30.0
@export var SHAKE_DECAY_RATE: float = 1.1
@export var EARTHQUAKE_DURATION: float = 6.0
@export var DELAY_BEFORE_EARTHQUAKE: float = 2.0
@export var lantern_picked_up: bool = false

enum ShakeType {
	Random,
	Noise,
	Sway
}

var player: Player:
	get: return WorldState.get_player();
var camera: Camera2D:
	get: return player.get_node("Camera2D");

@onready var noise = FastNoiseLite.new()
@onready var rand = RandomNumberGenerator.new()
@onready var lantern = $"Future/Lantern"
@onready var rubble: Sprite2D = $"Future/Entryway/rubble"
@onready var earthquake_timer = Timer.new()

var noise_i: float = 0.0
var shake_type: int = ShakeType.Random
var shake_strength: float = 0.0
var earthquake_active: bool = false

func _ready() -> void:
	super._ready();

	DialogState.start_dialog(load('res://scenes/dialogue/LabInterior.dialogue'), 'start_of_game_text')
	rand.randomize()
	noise.seed = rand.randi()
	noise.frequency = 0.5
	
	add_child(earthquake_timer)
	earthquake_timer.wait_time = DELAY_BEFORE_EARTHQUAKE
	earthquake_timer.one_shot = true
	earthquake_timer.connect("timeout", Callable(self, "_on_earthquake_timer_timeout"))

	switch_time(WorldState.in_future)

func _on_lantern_interacted(_initiator):
	if WorldState.lantern_unlocked: return ;

	WorldState.disable_movement = true;

	lantern.visible = false
	lantern.queue_free()
	
	await DialogState.start_dialog(load('res://scenes/dialogue/LabInterior.dialogue'), 'lantern_picked_up')

	player.direction = Vector2.UP;
	$AudioStreamPlayer2D.play()
	earthquake_timer.start()

func _on_earthquake_timer_timeout():
	shake_strength = RANDOM_SHAKE_STRENGTH
	shake_type = ShakeType.Random
	earthquake_timer = EARTHQUAKE_DURATION
	earthquake_active = true

func _process(delta: float) -> void:
	if !earthquake_active: return
	
	earthquake_timer -= delta
	if earthquake_timer <= 2:
		rubble.visible = true
	if earthquake_timer <= 0:
		WorldState.disable_movement = false;
		WorldState.lantern_unlocked = true;
		earthquake_active = false
		shake_strength = 0.0
	else:
		shake_strength = lerp(shake_strength, 0.0, SHAKE_DECAY_RATE * delta)
		var shake_offset: Vector2
		match shake_type:
			ShakeType.Random:
				shake_offset = get_random_offset()
			ShakeType.Noise:
				shake_offset = get_noise_offset(delta, NOISE_SHAKE_SPEED, shake_strength)
			ShakeType.Sway:
				shake_offset = get_noise_offset(delta, NOISE_SWAY_SPEED, NOISE_SWAY_STRENGTH)
		camera.offset = shake_offset

func get_noise_offset(delta: float, speed: float, strength: float) -> Vector2:
	noise_i += delta * speed
	return Vector2(
		noise.get_noise_2d(1, noise_i) * strength,
		noise.get_noise_2d(100, noise_i) * strength
	)

func get_random_offset() -> Vector2:
	return Vector2(
		rand.randf_range( - shake_strength, shake_strength),
		rand.randf_range( - shake_strength, shake_strength)
	)

func _on_entryway_text_body_entered(_body):
	if WorldState.in_future:
		if !WorldState.lantern_unlocked:
			DialogState.start_dialog(load('res://scenes/dialogue/LabInterior.dialogue'), 'try_leave_lab_without_lantern')
		else:
			DialogState.start_dialog(load('res://scenes/dialogue/LabInterior.dialogue'), 'interact_rubble')

func switch_time(to_future: bool):
	print("switching time in lab-0")
	$"Future".visible = to_future;
	$"Past".visible = !to_future;
	$"CanvasLayer/ColorRect".color = Color.BLACK if to_future else Color.WHITE;