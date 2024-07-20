extends Node

var in_future: bool = false;

func use_lantern() -> void:
	set_time(!in_future)
	print("todo: lantern, now in future: " + str(in_future))

func set_time(to_future: bool) -> void:
	in_future = to_future;
	SoundPlayer.set_music_track(in_future, 1)
