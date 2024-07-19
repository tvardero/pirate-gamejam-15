extends Node2D

var code = "01" #Code for unlocking the gate (0- lever closed, 1- lever open)
var codeFromLevers = ""
var levers = []
@onready var collision_shape_2d = $StaticBody2D/CollisionShape2D

func _ready():
	levers = get_node("Levers").get_children()
	WorldState.connect("LeverChanged",Callable(self, "check_code"))
	for lever in levers:
		print(lever.name, ' ', lever.state)

func check_code():
	var codeFromLevers = ""
	for lever in levers:
		codeFromLevers += lever.state
	
	if code == codeFromLevers:
		collision_shape_2d.disabled = true
	else:
		collision_shape_2d.disabled = false
