## This is the global config for the game.
## It contains all the configuration for the aquarium game.
extends Node


signal debug_mode_changed(new_value: bool)


## Debug mode active or not
@export var debug_mode: bool = true:
	get:
		return debug_mode
	set(value):
		debug_mode = value
		emit_signal("debug_mode_changed", value)
