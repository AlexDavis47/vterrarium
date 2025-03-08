@tool
extends Resource
class_name CreatureHungerData

## The current satiation (fullness) of the creature
## Ranges from 0.0 (starving) to 1.0 (completely full)
@export var satiation: FloatWithModifiers = FloatWithModifiers.create(1.0).clamped(0.0, 1.0)

## The rate per hour at which the creature will lose satiation.
## Higher values make the creature get hungry faster
@export var hunger_rate: FloatWithModifiers = FloatWithModifiers.create(1.0)


func get_current_satiation() -> float:
	return satiation.modified_value

func get_current_hunger_rate() -> float:
	return hunger_rate.modified_value
