extends Level

@export var NOISE_SHAKE_SPEED: float = 30.0
@export var NOISE_SWAY_SPEED: float = 1.0
@export var NOISE_SHAKE_STRENGTH: float = 60.0
@export var NOISE_SWAY_STRENGTH: float = 10.0
@export var RANDOM_SHAKE_STRENGTH: float = 30.0
@export var SHAKE_DECAY_RATE: float = 1.1
@export var EARTHQUAKE_DURATION: float = 6.0 
@export var DELAY_BEFORE_EARTHQUAKE: float = 2.0
@export var lantern_picked_up: bool=false

# Used so we can pause the player's movements
var player: Player

enum ShakeType {
	Random,
	Noise,
	Sway
}

@onready var camera = $Player/Camera2D
@onready var noise = FastNoiseLite.new()
@onready var rand = RandomNumberGenerator.new()
@onready var lantern = $Lantern
@onready var rubble = $Future/Entryway/rubble
@onready var earthquake_timer = Timer.new()

var noise_i: float = 0.0
var shake_type: int = ShakeType.Random
var shake_strength: float = 0.0
var earthquake_active: bool = false
var lantern_interacted: bool = false

func _ready() -> void:
	DialogState.start_dialog(load('res://scenes/dialogue/LabInterior.dialogue'), 'start_of_game_text')
	rand.randomize()
	noise.seed = rand.randi()
	noise.frequency = 0.5
	
	add_child(earthquake_timer)
	earthquake_timer.wait_time = DELAY_BEFORE_EARTHQUAKE
	earthquake_timer.one_shot = true
	earthquake_timer.connect("timeout", Callable(self, "_on_earthquake_timer_timeout"))
	
	lantern.connect("interacted", Callable(self, "_on_lantern_interacted"))
	rubble.visible = false 

func _on_lantern_interacted(_initiator):
	player = $Player
	player.process_mode = Node.PROCESS_MODE_DISABLED
	if not lantern_interacted:
		lantern_interacted = true
		lantern.visible = false
		lantern.queue_free()
		await DialogState.start_dialog(load('res://scenes/dialogue/LabInterior.dialogue'), 'lantern_picked_up')
		lantern_picked_up = true
		$AudioStreamPlayer2D.play()
		earthquake_timer.start()

func _on_earthquake_timer_timeout():
	start_earthquake()

func start_earthquake():
	shake_strength = RANDOM_SHAKE_STRENGTH
	shake_type = ShakeType.Random
	earthquake_timer = EARTHQUAKE_DURATION
	earthquake_active = true

func _process(delta: float) -> void:
	
	if !earthquake_active: return
	
	earthquake_timer -= delta
	if earthquake_timer <= 2:
		switch_background()
	if earthquake_timer <= 0:
		earthquake_active = false
		shake_strength = 0.0
		player.process_mode = Node.PROCESS_MODE_INHERIT
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
		rand.randf_range(-shake_strength, shake_strength),
		rand.randf_range(-shake_strength, shake_strength)
	)

func switch_background():
	rubble.visible = true

func _on_entryway_text_body_entered(_body):
	if WorldState.in_future:
		if !lantern_picked_up:
			DialogState.start_dialog(load('res://scenes/dialogue/LabInterior.dialogue'), 'try_leave_lab_without_lantern')
		else:
			DialogState.start_dialog(load('res://scenes/dialogue/LabInterior.dialogue'), 'interact_rubble')

		
