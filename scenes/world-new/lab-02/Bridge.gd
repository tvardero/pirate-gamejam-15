extends Level

@export var first_visit: bool = true
var dialog_resource: DialogueResource = preload('res://scenes/dialogue/Bridge.dialogue')

func _ready():
	super()
	
	if WorldState.in_future: trigger_dialog(true)
	else: WorldState.time_changed.connect(trigger_dialog)

	var star_fragment = get_node_or_null("Future/StarFragment")
	if star_fragment: 
		star_fragment.collected.connect(_on_collected)


func trigger_dialog(_in_future: bool):
	if !first_visit: return
	DialogState.start_dialog(dialog_resource, 'enter_bridge_scene_first_time')
	first_visit = false


func _on_collected():
	DialogState.start_dialog(dialog_resource, 'after_fusing_first_star_fragment')
