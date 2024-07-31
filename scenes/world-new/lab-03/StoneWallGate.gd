extends Node2D

var _closed: bool = true;

var dialog = load("res://scenes/dialogue/PoliceOfficer.dialogue") as DialogueResource
@onready var sound = $"AudioStreamPlayer2D"

@export var closed: bool:
	get: return _closed;
	set(value): _set_closed(value)

# Called when the node enters the scene tree for the first time.
func _ready():
	closed = true;

func _set_closed(value: bool):
	_closed = value;
	$"ClosedGate".visible = _closed;
	$"Gate/CollisionShape2D".disabled = !_closed;

func _on_interactable_interacted(_initiator:Node):
	if WorldState.in_future:
		DialogState.start_dialog(dialog, "try_gate_in_present")
	else: 
		sound.play();
		closed = false;
