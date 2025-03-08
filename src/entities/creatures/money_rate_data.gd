@tool
extends Resource
class_name CreatureMoneyRateData

## The base money rate of the creature per second
@export var base_rate: FloatWithModifiers

func _init() -> void:
    if not base_rate:
        base_rate = FloatWithModifiers.create(1.0)

## Get the current money rate with all modifiers applied
func get_current_rate() -> float:
    return base_rate.modified_value