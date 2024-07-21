extends Node2D

@onready var collision_shape = $StaticBody2D/CollisionShape2D

func set_collision_enabled(enabled: bool):
	collision_shape.disabled = not enabled
