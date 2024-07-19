extends Node2D

@export var NOISE_SHAKE_SPEED: float = 30.0
@export var NOISE_SWAY_SPEED: float = 1.0
@export var NOISE_SHAKE_STRENGTH: float = 60.0
@export var NOISE_SWAY_STRENGTH: float = 10.0
@export var RANDOM_SHAKE_STRENGTH: float = 30.0
@export var SHAKE_DECAY_RATE: float = 3.0

enum ShakeType {
	Random,
	Noise,
	Sway
}

@onready var camera = $Camera2D
@onready var noise = FastNoiseLite.new()
@onready var rand = RandomNumberGenerator.new()
@onready var shake_timer = $Timer  # Make sure to add a Timer node and set it up

var noise_i: float = 0.0
var shake_type: int = ShakeType.Random
var shake_strength: float = 0.0

func _ready() -> void:
	rand.randomize()
	noise.seed = rand.randi()
	noise.frequency = 0.5
	
	# Start the timer
	shake_timer.start()

func _on_Timer_timeout() -> void:
	apply_random_shake()

func apply_random_shake() -> void:
	shake_strength = RANDOM_SHAKE_STRENGTH
	shake_type = ShakeType.Random
	
func apply_noise_shake() -> void:
	shake_strength = NOISE_SHAKE_STRENGTH
	shake_type = ShakeType.Noise
	
func apply_noise_sway() -> void:
	shake_type = ShakeType.Sway
	
func _process(delta: float) -> void:
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
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)
