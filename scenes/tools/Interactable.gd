@tool

class_name Interactable
extends Node2D

signal interacted(initiator: Node)

var _shape: Shape2D;

@export var shape: Shape2D:
	get: return _shape;
	set(value):
		_shape = value;
		_updateShape();

@onready var _collider: CollisionShape2D = $"Area2D/CollisionShape2D";

func _ready():
	_updateShape();

func interact(initiator: Node):
	interacted.emit(initiator)

func _updateShape():
	if _collider != null:
		_collider.shape = _shape;
