extends StaticBody2D



func _on_interactable_interacted(initiator):
	if initiator is Player:
		if WorldState.password_found == false:
			DialogState.start_dialog(load('res://scenes/dialogue/Clubhouse.dialogue'), 'partygoer')
		else:
			DialogState.start_dialog(load('res://scenes/dialogue/Clubhouse.dialogue'), 'partygoer_after_password_seen')
