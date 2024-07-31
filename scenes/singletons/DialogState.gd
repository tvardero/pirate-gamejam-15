extends Node

@onready var dialogue_manager: DialogueManager = Engine.get_singleton("DialogueManager")
const balloon_packed = preload("res://scenes/ui/DialogBalloon.tscn")
var balloon: DialogBalloon
var disabled: bool:
	set(val):
		if val == disabled: return
		disabled = val
		if !val: enabled.emit()
signal enabled

var char_vars: Dictionary = {}


func _ready():
	# Load all player emote sprites
	var char_var_dir = "res://resources/dialog_char_vars/"
	var files = DirAccess.open(char_var_dir).get_files()
	for file in files:
		if file.ends_with(".remap"):
			file = file.trim_suffix(".remap")
		char_vars[file] = load(char_var_dir + "/" + file)

func create_balloon() -> DialogBalloon:
	if disabled: await enabled
	balloon = balloon_packed.instantiate()
	WorldState.get_current_level().add_child(balloon)
	return balloon

func start_dialog(dialogue_resource: DialogueResource, dialogue_start: String = 'Start'):
	await create_balloon()
	balloon.start(dialogue_resource, dialogue_start)
	await dialogue_manager.dialogue_ended
	balloon = null

# For creating dialogue lines on the fly
func start_from_text(text: String):
	text = '~ Start\n' + text
	var resource: DialogueResource = dialogue_manager.create_resource_from_text(text)
	await start_dialog(resource)


func get_char_vars(character: String) -> DialogCharVars:
	if char_vars.has(character + ".tres"):
		return char_vars[character + ".tres"]
	return null
