extends Node2D

var dialog = load("res://scenes/dialogue/PoliceOfficer.dialogue") as DialogueResource
@onready var sound = $"AudioStreamPlayer2D"
var lastState : bool;

# Called when the node enters the scene tree for the first time.
func _ready():
	lastState = WorldState.town1_gate_open;
	_set_closed()

func _process(delta):
	if(lastState != WorldState.town1_gate_open):
		lastState = WorldState.town1_gate_open;
		_set_closed();
		
func _set_closed():
	$"ClosedGate".visible = !WorldState.town1_gate_open;
	$"Gate/CollisionShape2D".disabled = WorldState.town1_gate_open;

func _on_interactable_interacted(_initiator:Node):
	if WorldState.in_future:
		DialogState.start_dialog(dialog, "try_gate_in_present")
	else: 
		sound.play();
		await get_tree().create_timer(1).timeout
		WorldState.town1_gate_open = true;
		_set_closed()
