extends Node2D

@onready var _anim: AnimationPlayer = $"AnimationPlayer";

# Called when the node enters the scene tree for the first time.
func _ready():
	if !WorldState.sewage_valve_off: 
		_anim.play("flow")
		$"ValveClosed".hide()
	else:
		$"ValveClosed".show()

func close():
	_anim.stop();
	$"ValveClosed".show()
	WorldState.sewage_valve_off = true;

func _on_interactable_interacted(_initiator:Node):
	print("pipe interacted")
	close()
