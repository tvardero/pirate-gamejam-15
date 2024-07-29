extends Level

var dialog_resource = preload ('res://scenes/dialogue/LabExterior.dialogue') as DialogueResource;
@export var first_visit: bool = true;
@export var gate_puzzle_solved: bool = false;

func _ready():
	super();

	if first_visit:
		DialogState.start_dialog(dialog_resource, 'exited_lab')
		first_visit = false

func _on_lab_building_interacted(_initiator: Node):
	if WorldState.in_future:
		DialogState.start_dialog(dialog_resource, 'try_lab_entrance_future')
	else:
		DialogState.start_dialog(dialog_resource, 'try_lab_entrance_past')

func _on_gate_interacted(_initiator: Node):
	if !WorldState.in_future&&!gate_puzzle_solved:
		DialogState.start_dialog(dialog_resource, 'try_gate_in_past')

func _on_puzzle_solved_body_entered(body:Node2D):
	if body is Player:
		gate_puzzle_solved = true;
		$"PuzzleSolved".set_collision_mask_value(2, false)
		DialogState.start_dialog(dialog_resource, 'puzzle_solved')
