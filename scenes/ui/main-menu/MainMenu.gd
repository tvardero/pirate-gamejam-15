extends Control

@export var first_level: PackedScene;

func _ready():
	%"Start".grab_focus()

func start_game():
	WorldState.reset()
	WorldState.transit_player_to_scene(first_level, 0, Vector2.DOWN)

func _on_start_button_down():
	start_game()
	queue_free()