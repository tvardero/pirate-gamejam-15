extends CanvasLayer

@onready var color_rect: ColorRect = $ColorRect
@export var anim_length: float = 1
@export var curve: Curve

var time: float = 0
signal halfway
signal finished


func _ready():
	stop()


func start(length: float = anim_length):
	color_rect.color = Color.BLACK if WorldState.in_future else Color.WHITE
	anim_length = length
	time = 0
	visible = true


func _process(delta):
	if !visible: return
	if time >= anim_length: return stop()
	
	if time >= anim_length / 2: halfway.emit()
	
	var prog: float = time / anim_length
	color_rect.color.a = curve.sample(prog)
	
	time += delta


func stop():
	visible = false
	finished.emit()
