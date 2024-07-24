extends StaticBody2D

signal interacted(initiator)
@onready var interactable = $Interactable

@export var canvas_layer_path: NodePath

@onready var canvas_layer = get_node(canvas_layer_path)

var overlay_visible = false

func _ready():
	if canvas_layer:
		canvas_layer.visible = false
	
	if not interactable.is_connected("interacted", Callable(self, "_on_interactable_interacted")):
		interactable.connect("interacted", Callable(self, "_on_interactable_interacted"))

func _on_interactable_interacted(initiator):
	if initiator is Node2D:
		show_overlay()

func show_overlay():
	if canvas_layer:
		canvas_layer.visible = true
		overlay_visible = true

func _input(event):
	if overlay_visible and event is InputEventKey and event.pressed:
		hide_overlay()

func hide_overlay():
	if canvas_layer:
		canvas_layer.visible = false
		overlay_visible = false
