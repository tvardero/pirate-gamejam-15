extends Node

var in_future: bool = false;

func use_lantern() -> void:
    print("todo: lantern, now in future: " + str(in_future))
    set_time(!in_future)

func set_time(to_future: bool) -> void:
    in_future = to_future;