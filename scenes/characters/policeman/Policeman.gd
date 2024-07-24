extends StaticBody2D

func _on_interactable_interacted(initiator: Node):
	if initiator is Player:
		if WorldState.newspaper_picked_up == false:
			DialogState.start_dialog(load('res://scenes/dialogue/PoliceOfficer.dialogue'), 'police_officer')
		elif WorldState.newspaper_picked_up == true:
			await DialogState.start_dialog(load('res://scenes/dialogue/PoliceOfficer.dialogue'), 'police_after_finding_newspaper')
			WorldState.policeman_moved=true
			self.queue_free()
