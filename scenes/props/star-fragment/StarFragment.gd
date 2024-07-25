extends Node2D

func _on_interactable_interacted(_initiator: Node):
	visible = false
	await DialogState.start_from_text('Found a Star Fragment!')
	WorldState.star_fragment_count += 1
	queue_free()
