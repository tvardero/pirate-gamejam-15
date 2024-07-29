extends Level

var dialog_resource: DialogueResource = preload('res://scenes/dialogue/Bridge.dialogue')

func _ready():
	super()

	var star_fragment = get_node_or_null("Future/StarFragment")
	if star_fragment: 
		star_fragment.collected.connect(_on_collected)
		DialogState.start_dialog(dialog_resource, 'enter_bridge_scene_first_time')

func _on_collected():
	DialogState.start_dialog(dialog_resource, 'after_fusing_first_star_fragment')
