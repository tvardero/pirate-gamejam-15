class_name Portrait
extends Control

var sprites: Array[PortraitSprite]


func _ready():
	for child in get_children():
		if child is PortraitSprite: sprites.append(child)


func animate(delta: float):
	for sprite in sprites:
		if !sprite.ap: continue
		sprite.ap.advance(delta)


func stop():
	for sprite in sprites:
		if sprite.continuous || !sprite.ap: continue
		sprite.ap.stop()
