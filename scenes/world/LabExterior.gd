extends Level

var dialog_resource: DialogueResource = preload('res://scenes/dialogue/LabExterior.dialogue')
@export var first_visit: bool = true

@export var entrance_text_area: Area2D
@export var gate_text_area: Area2D


func _ready():
	super()
	
	entrance_text_area.body_entered.connect(_on_entrance_text_area_body_entered)
	gate_text_area.body_entered.connect(_on_gate_text_area_body_entered)
	gate_text_area.body_exited.connect(_on_gate_text_area_body_exited)
	
	if first_visit:
		DialogState.start_dialog(dialog_resource, 'exited_lab')
		first_visit = false


func _on_entrance_text_area_body_entered(body):
	if body is Player:
		DialogState.start_dialog(dialog_resource, 'try_lab_entrance_past')
		entrance_text_area.set_deferred('monitoring', false)


func _on_gate_text_area_body_entered(body):
	if WorldState.in_future: return
	if body is Player:
		DialogState.start_dialog(dialog_resource, 'try_gate_in_past')
		gate_text_area.set_deferred('monitoring', false)


func _on_gate_text_area_body_exited(body):
	if body is Player:
		if body.position.x >= gate_text_area.position.x:
			gate_text_area.set_deferred('monitoring', false)
