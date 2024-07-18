extends Node

var in_future: bool = false;

func use_lantern() -> void:
    timeshift(!in_future)

func timeshift(to_future: bool) -> void:
    in_future = to_future;