extends Node2D

@onready var collision_shape_closed = $"Gate Closed/CollisionShape2D"
@onready var collision_shape_open = $"Gate Open/CollisionShape2D"
@onready var gate_open = $"Gate Open"
@onready var gate_closed = $"Gate Closed"

func _ready():
	if WorldState.town1_gate_open == true:
		collision_shape_closed.disabled = true
		collision_shape_open.disabled = false
		gate_closed.visible = false
		gate_open.visible = true
	else:
		collision_shape_closed.disabled = false
		collision_shape_open.disabled = true
		gate_closed.visible = true
		gate_open.visible = false

func _on_interactable_interacted(initiator):
	if WorldState.policeman_moved == true:
		if initiator is Node2D:
			SoundPlayer.play_sound(load('res://assets/sounds/gate/gate.wav'))
			await get_tree().create_timer(1.0).timeout
			collision_shape_closed.disabled = true
			collision_shape_open.disabled = false
			gate_closed.visible = false
			gate_open.visible = true
			WorldState.town1_gate_open = true
