extends Resource
class_name HungerComponentData

## The amount of satiation the creature has
@export var satiation: float = 1.0:
	get:
		return satiation
	set(value):
		satiation = clamp(value, 0.0, 1.0)

## What percentage of the creature's max hunger value it will lose per hour
@export var hunger_rate: float = 1.0

## Whether the creature is starving
var _is_starving: bool = false


## Called by the creature when it is serialized
func serialize() -> Dictionary:
	return {
		"satiation": satiation,
		"hunger_rate": hunger_rate,
		"is_starving": _is_starving
	}

## Called by the creature when it is deserialized
func deserialize(data: Dictionary):
	satiation = data.get("satiation", 1.0)
	hunger_rate = data.get("hunger_rate", 1.0)
	_is_starving = data.get("is_starving", false)
