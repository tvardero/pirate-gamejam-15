extends Level

var dialog_resource: DialogueResource = preload('res://scenes/dialogue/Bridge.dialogue')
@export var first_visit: bool = true

@export var star_fragment: Node2D


func _ready():
	WorldState.time_changed.connect(trigger_dialog)
	
	super()
	
	if is_instance_valid(star_fragment):
		star_fragment.collected.connect(_on_star_fragment_collected)


func trigger_dialog(in_future: bool):
	if !in_future: return
	if !first_visit: return
	
	DialogState.start_dialog(dialog_resource, 'enter_bridge_scene_first_time')
	first_visit = false


func _on_star_fragment_collected():
	DialogState.start_dialog(dialog_resource, 'after_fusing_first_star_fragment')
