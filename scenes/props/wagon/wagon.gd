extends StaticBody2D

@export var past_wagon: Pushable
var dialog_resource: DialogueResource = preload('res://scenes/dialogue/Wagon.dialogue')


func _ready():
	if past_wagon:
		past_wagon.pushed.connect(_on_past_wagon_pushed)


func _on_past_wagon_pushed(pos: Vector2):
	position = pos


func _on_interactable_interacted(initiator):
	if !(initiator is Player): return
	
	DialogState.start_dialog(dialog_resource, 'try_wagon_present')
