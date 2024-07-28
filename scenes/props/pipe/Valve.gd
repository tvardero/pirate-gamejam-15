extends StaticBody2D

var dialog_resource: DialogueResource = preload('res://scenes/dialogue/SewageValve.dialogue')
@onready var anim: AnimationPlayer = $AnimationPlayer


func _ready():
	$Interactable.interacted.connect(_on_interactable_interacted)
	WorldState.time_changed.connect(_on_time_changed)


func _on_interactable_interacted(initiator):
	if !(initiator is Player): return
	if WorldState.sewage_valve_off: return
	
	if WorldState.in_future:
		DialogState.start_dialog(dialog_resource, 'try_valve_present')
	else:
		print('turned sewage valve off')
		WorldState.sewage_valve_off = true
		anim.stop()
		# TODO: Make separate script for pipe in Town2


func _on_time_changed(in_future: bool):
	if in_future || WorldState.sewage_valve_off: anim.stop()
	else: anim.play('Flowing')
