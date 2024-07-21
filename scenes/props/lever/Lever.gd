extends StaticBody2D

@export var gate_path: NodePath

@onready var gate = get_node(gate_path)
@onready var sprite = $Sprite2D

var pressed: bool = false

func _on_interactable_interacted(initiator):
	if initiator is Node2D:
		toggle_gate_collision()

func toggle_gate_collision():
	if gate:
		pressed = !pressed
		gate.set_collision_enabled(!pressed)
		if pressed:
			sprite.flip_h = true
		else:
			sprite.flip_h = false
