class_name DialogSpritesheet
extends Resource

@export var spritesheet: Texture2D
@export var h_frames: int = 1
@export var v_frames: int = 1
@export var framerate: float = 6
@export var continuous: bool = false
var curr_ap: AnimationPlayer

var frame_count: int:
	get:
		return h_frames * v_frames
