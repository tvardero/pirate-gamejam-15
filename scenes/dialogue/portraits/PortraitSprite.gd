class_name PortraitSprite
extends Sprite2D

@onready var ap: AnimationPlayer = get_node_or_null('AnimationPlayer')
@export var continuous: bool = false


func _ready():
	centered = false
	offset.y = -texture.get_height()
	if ap: set_anim()


func set_anim():
	for anim in ap.get_animation_list():
		if anim == 'RESET': continue
		ap.assigned_animation = anim
