extends Node2D
@onready var newspaper = $"."

func _ready():
	$AnimationPlayer.play('idle')
	if WorldState.newspaper_picked_up == true:
		newspaper.queue_free()

func _on_interactable_interacted(initiator):
	if WorldState.in_future == true:
		if initiator is Player:
			WorldState.disable_movement = true
			visible=false
			SoundPlayer.play_sound(load('res://assets/sounds/newspaper/newspaper.wav'))
			await get_tree().create_timer(1.0).timeout
			DialogState.start_dialog(load('res://scenes/dialogue/PoliceOfficer.dialogue'), 'pick_up_newspaper')
			WorldState.newspaper_picked_up = true
			WorldState.disable_movement = false
			newspaper.queue_free()
