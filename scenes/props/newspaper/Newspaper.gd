extends Node2D
@onready var newspaper = $"."

func _ready():
	if WorldState.newspaper_picked_up == true:
		newspaper.queue_free()

func _on_interactable_interacted(initiator):
	if WorldState.in_future == true:
		if initiator is Node2D:
			DialogState.start_dialog(load('res://scenes/dialogue/PoliceOfficer.dialogue'), 'pick_up_newspaper')
			WorldState.newspaper_picked_up = true
			newspaper.queue_free()
