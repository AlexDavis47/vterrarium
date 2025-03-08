@tool
extends Resource
class_name CreatureHappinessData

## The base happiness of the creature (0.0 to 1.0)
@export var base_happiness: FloatWithModifiers

func _init() -> void:
	if not base_happiness:
		base_happiness = FloatWithModifiers.create(1.0).clamped(0.0, 1.0)

## Get the current happiness with all modifiers applied
func get_current_happiness() -> float:
	return base_happiness.modified_value
