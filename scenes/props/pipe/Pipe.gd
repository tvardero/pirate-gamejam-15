extends StaticBody2D

var dialog_resource: DialogueResource = preload('res://scenes/dialogue/SewageValve.dialogue')


func _on_interactable_interacted(initiator):
	if !(initiator is Player): return
	if WorldState.sewage_valve_off: return
	
	if WorldState.in_future:
		DialogState.start_dialog(dialog_resource, 'try_valve_present')
	else:
		# TODO: Play animation
		print('turned sewage valve off')
		WorldState.sewage_valve_off = true
		# TODO: Make separate script for pipe in Town2
