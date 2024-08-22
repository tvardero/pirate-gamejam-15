class_name MASK
extends Sprite2D


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	position = WorldState.player.position;

	print_debug(self.scale);
	pass

func change(changeState : bool):
	if(changeState):
		self.scale = (Vector2(0,0));
		visible = true;
		while(self.scale < Vector2(1,1)):
			await get_tree().create_timer(1.0/60.0).timeout
			if(self.scale >= Vector2(1,1)):
				self.scale = (Vector2(1,1));
				break;
			else:
				self.scale = (self.scale + Vector2(1.0/60.0,1.0/60.0));
	else:
		self.scale = (Vector2(1,1));
		while(self.scale > Vector2(0,0)):
			await get_tree().create_timer(1.0/60.0).timeout
			if(self.scale <= Vector2(0,0)):
				self.scale = (Vector2(0,0));
				break;
			else:
				self.scale = (self.scale - Vector2(1.0/60.0,1.0/60.0));
		visible = false;
