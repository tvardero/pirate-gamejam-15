extends StaticBody2D

@onready var collision_shape = $CollisionShape2D

func _ready():
	if WorldState.policeman_moved == true:
		disable_gate_collider()
	
	WorldState.connect("policeman_moved_changed", Callable(self, "_on_policeman_moved_changed"))

func _on_policeman_moved_changed(moved):
	if moved:
		disable_gate_collider()

func disable_gate_collider():
	if collision_shape:
		collision_shape.disabled = true
		print("Gate collider disabled")
