@tool
extends Resource
class_name CreatureSpeedData

## The base speed of the creature in units per second
@export var base_speed: FloatWithModifiers

func _init() -> void:
	if not base_speed:
		base_speed = FloatWithModifiers.create(1.0)

## Get the current speed with all modifiers applied
func get_current_speed() -> float:
	return base_speed.modified_value
