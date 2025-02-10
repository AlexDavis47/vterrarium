extends Node

var shared_screen_layer: int = 1
var primary_screen_layer: int = 2
var secondary_screen_layer: int = 3

enum Screen {
	SHARED = 1,
	PRIMARY = 2,
	SECONDARY = 3
}

func get_shared_screen_layer() -> int:
	return shared_screen_layer

func get_primary_screen_layer() -> int:
	return primary_screen_layer

func get_secondary_screen_layer() -> int:
	return secondary_screen_layer
