extends StaticBody2D

@export var past_wagon: Pushable


func _ready():
	if past_wagon:
		past_wagon.pushed.connect(_on_past_wagon_pushed)


func _on_past_wagon_pushed(pos: Vector2):
	position = pos
