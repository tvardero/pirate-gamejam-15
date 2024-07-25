extends CanvasLayer


func _ready():
	visible = false


func toggle():
	if is_instance_valid(DialogState.balloon): return
	
	if !visible: pause()
	else: resume()


func pause():
	get_tree().paused = true
	%StarCount.text = '  ' + str(WorldState.star_fragment_count)
	visible = true


func resume():
	get_tree().paused = false
	visible = false


func _on_resume_pressed():
	resume()


func _on_quit_pressed():
	get_tree().quit()
