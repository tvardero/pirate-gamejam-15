extends StaticBody2D

signal interacted(initiator)
@onready var interactable = $Interactable

func _ready():
	if not interactable.is_connected("interacted", Callable(self, "_on_interactable_interacted")):
		interactable.connect("interacted", Callable(self, "_on_interactable_interacted"))

func _on_interactable_interacted(initiator):
	if initiator is Node2D:
		print("Interacted")
		emit_signal("interacted", initiator)
