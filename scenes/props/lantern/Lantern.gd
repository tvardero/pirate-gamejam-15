extends Node2D

func _ready() :
	$"AnimationPlayer".play("idle")

func _on_interactable_interacted(_initiator:Node):
	print("lantern interacted")
	pass # Replace with function body.
