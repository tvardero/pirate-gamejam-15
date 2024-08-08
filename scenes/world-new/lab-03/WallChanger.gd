extends Sprite2D

@export var night_image : Texture2D;
@export var day_image : Texture2D;
var lastState : bool;
var isChanging : bool = false;

func _ready():
	lastState = WorldState.in_future;
	isChanging = true;
	changeImage(lastState);

func _process(delta):
	if WorldState.in_future != lastState and !isChanging:
		lastState = WorldState.in_future;
		isChanging = true;
		await changeImage(lastState);

func changeImage(in_future : bool):
	if in_future:
		await get_tree().create_timer(1.0).timeout
		self.texture = night_image;
	else:
		await get_tree().create_timer(1.0).timeout
		self.texture = day_image;
	isChanging = false;

	
