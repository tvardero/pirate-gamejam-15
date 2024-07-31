extends StaticBody2D


func _on_interactable_interacted(initiator: Node):
	if initiator is Player:
		if WorldState.newspaper_picked_up == false:
			DialogState.start_dialog(load('res://scenes/dialogue/PoliceOfficer.dialogue'), 'police_officer')
			WorldState.police_before_newspaper=true
		elif WorldState.newspaper_picked_up == true:
			if WorldState.police_before_newspaper == true:
				await DialogState.start_dialog(load('res://scenes/dialogue/PoliceOfficer.dialogue'), 'police_after_finding_newspaper')
			elif WorldState.police_before_newspaper == false: #If you went straight to the newspaper without talking to the police officer first
				await DialogState.start_dialog(load('res://scenes/dialogue/PoliceOfficer.dialogue'), 'police_officer_first_time_after_newspaper')
			WorldState.policeman_moved=true
			self.queue_free()
