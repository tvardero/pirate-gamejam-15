extends Node

@onready var dialogue_manager: DialogueManager = Engine.get_singleton("DialogueManager")
const balloon_packed = preload("res://scenes/ui/DialogBalloon.tscn")
var balloon: DialogBalloon


func create_balloon() -> DialogBalloon:
	balloon = balloon_packed.instantiate()
	get_tree().current_scene.add_child(balloon)
	return balloon


func start_dialog(dialogue_resource: DialogueResource, dialogue_start: String = 'Start'):
	create_balloon()
	balloon.start(dialogue_resource, dialogue_start)
	await dialogue_manager.dialogue_ended
	balloon = null

# For creating dialogue lines on the fly
func start_from_text(text: String):
	text = '~ Start\n' + text
	var resource: DialogueResource = dialogue_manager.create_resource_from_text(text)
	await start_dialog(resource)
