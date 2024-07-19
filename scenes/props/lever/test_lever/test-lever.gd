extends Node2D

var state = "0"
@onready var player = $"../../../Player"

func ready():
	flip_sprite()

func _process(delta):
	if $Area2D.overlaps_body(player) and Input.is_action_just_pressed("interaction"):
		if state == "0":
			state = "1"
		else:
			state = "0"		
	flip_sprite()
	WorldState.lever_changed()

func flip_sprite():
	if state == "0":
		$Sprite2D.flip_h = true
	else:
		$Sprite2D.flip_h = false
