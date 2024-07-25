extends Node2D

@onready var anim = $"../AnimatedSprite2D"
@onready var instructions = $"../Label"

@onready var build_sfx = preload('res://assets/sounds/lantern/fuse-build.wav')
@onready var woosh_sfx = preload('res://assets/sounds/lantern/fuse-woosh.wav')

var selected=false
var rest_point
var rest_nodes = []

func _ready():
	rest_nodes = get_tree().get_nodes_in_group("zone")
	rest_point = rest_nodes[0].global_position
	rest_nodes[0].select()

func _on_area_2d_input_event(_viewport, _event, _shape_idx):
	print(123)
	if Input.is_action_just_pressed("click"):
		selected=true
		instructions.visible = false

func _physics_process(delta):
	if selected:
		global_position = lerp(global_position, get_global_mouse_position(), 25*delta)
	else:
		global_position = lerp(global_position, rest_point, 10*delta)

func _input(event):
	if event is InputEventMouseButton:
		print(1)
		if event.button_index == MOUSE_BUTTON_LEFT and not event.pressed:
			print(2)
			selected = false
			var shortest_distance = 40
			for child in rest_nodes:
				print(3)
				var distance = global_position.distance_to(child.global_position)
				if distance < shortest_distance:
					print(4)
					child.select()
					rest_point=child.global_position
					shortest_distance = distance
					if child.is_destination: resolve()
					
func resolve():
	print(5)
	anim.play('play')
	SoundPlayer.play_sound(build_sfx)
	await get_tree().create_timer(0.4).timeout
	SoundPlayer.play_sound(woosh_sfx)
	await get_tree().create_timer(0.3).timeout
	get_parent().queue_free()
