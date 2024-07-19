extends StaticBody2D

@export
var movement_on_interaction: float = 100

func _on_interactable_interacted(initiator:Node):
	if initiator is Node2D:
		var direction_to_move = (position - initiator.position).normalized();
		var move_by = direction_to_move * movement_on_interaction;
		position = position + move_by;
