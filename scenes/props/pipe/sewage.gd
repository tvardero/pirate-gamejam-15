extends StaticBody2D

@onready var ap: AnimationPlayer = $AnimationPlayer
#@onready var shape: CollisionShape2D = $CollisionShape2D
@export var future_sewage: Node2D


func _ready():
	if !future_sewage:
		print('NULL')
		return
	print('OTHER')
	var other_ap: AnimationPlayer = future_sewage.get_node('AnimationPlayer')
	if WorldState.sewage_valve_off:
		ap.play('PastWeak')
		other_ap.play('PresentWeak')
	else:
		ap.play('PastStrong')
		other_ap.play('PresentStrong')
	
	
	if WorldState.sewage_valve_off:
		print('DISABLING')
		#shape.disabled = true
		future_sewage.set_collision_layer_value(2, 0)
		future_sewage.set_collision_mask_value(2, 0)
