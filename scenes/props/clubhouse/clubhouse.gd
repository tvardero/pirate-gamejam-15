extends StaticBody2D



func _on_interactable_interacted(initiator):
	if initiator is Node2D:
		if WorldState.in_future:
			DialogState.start_dialog(load('res://scenes/dialogue/Clubhouse.dialogue'), 'try_clubhouse_future')
		else:
			if !WorldState.password_found:
				DialogState.start_dialog(load('res://scenes/dialogue/Clubhouse.dialogue'), 'try_clubhouse_past')
			else:
				DialogState.start_dialog(load('res://scenes/dialogue/Clubhouse.dialogue'), 'clubhouse_past_with_password')
