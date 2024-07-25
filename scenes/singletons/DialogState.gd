extends Node

@onready var dialogue_manager: DialogueManager = Engine.get_singleton("DialogueManager")
const balloon_packed = preload("res://scenes/ui/DialogBalloon.tscn")
var balloon: DialogBalloon

var player_emote_textures: Dictionary = {}


func _ready():
	# Load all player emote sprites
	var player_emote_dir = "res://assets/sprites/player/emotes"
	var files = DirAccess.open(player_emote_dir).get_files()
	for file in files:
		if file.ends_with(".import"):
			continue
		if file.ends_with(".remap"):
			file = file.trim_suffix(".remap")
		var texture = load(player_emote_dir + '/' + file)
		player_emote_textures[file] = texture

func create_balloon() -> DialogBalloon:
	balloon = balloon_packed.instantiate()
	WorldState.get_current_level().add_child(balloon)
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


func emote(expression: String):
	for key in player_emote_textures.keys():
		print(key)
		if expression in key.to_lower():
			print(1)
			balloon.player_sprite.texture = player_emote_textures[key]
			return
