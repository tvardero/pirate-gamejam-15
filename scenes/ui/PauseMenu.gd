extends CanvasLayer


func _ready():
	%StarCount.text = ' ' + str(WorldState.star_fragment_count)


func resume():
	get_tree().paused = false
	queue_free()


func _on_resume_pressed():
	resume()


func _on_quit_pressed():
	get_tree().quit()
