extends CanvasLayer

func _ready():
	visible = false

func _process(_delta):
	if Input.is_action_just_pressed('pause'):
		toggle()

func toggle():
	if is_instance_valid(DialogState.balloon): return
	
	if !visible: pause()
	else: resume()

func pause():
	get_tree().paused = true
	%StarCount.text = '  ' + str(WorldState.star_fragment_count)
	%Resume.grab_focus()
	visible = true

func resume():
	get_tree().paused = false
	visible = false

func _on_resume_pressed():
	resume()

func _on_quit_pressed():
	get_tree().quit()