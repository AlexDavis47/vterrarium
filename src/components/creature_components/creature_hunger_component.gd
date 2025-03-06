## Component that manages creature hunger and satiation
##
## This component handles:
## - Tracking the creature's satiation level (fullness)
## - Decreasing satiation over time (hunger)
## - Updating happiness based on hunger level
@tool
extends CreatureComponent
class_name CreatureHungerComponent

## Signal emitted when the satiation value changes.
## @param value: The new satiation value
signal satiation_changed(value)

## The current satiation (fullness) of the creature
## Ranges from 0.0 (starving) to 1.0 (completely full)
@export var satiation: float = 1.0:
	get:
		return satiation
	set(value):
		satiation = clamp_value(value, 0.0, 1.0)
		emit_signal("satiation_changed", value)
		emit_signal("property_changed", "satiation", value)

## The rate per hour at which the creature will lose satiation.
## Higher values make the creature get hungry faster
@export var hunger_rate: float = 1.0

## Initialize the hunger component and set up modifiers
func _ready() -> void:
	# Set up a happiness modifier based on hunger
	var happiness = creature.creature_data.creature_happiness
	# When satiation is high, happiness is maximized (multiplied by 1.0)
	# When satiation is low, happiness is reduced (multiplied by a lower value)
	add_stat_modifier(happiness, "Hunger", satiation, happiness.MODIFIER_MULTIPLY)

## Update the satiation level and related modifiers
func _process(delta: float) -> void:
	# Decrease satiation over time based on hunger_rate
	# Delta is converted from seconds to hours for the calculation
	satiation -= hunger_rate * (delta / 3600.0)
	
	# Update the happiness modifier with the new satiation value
	update_stat_modifier("Hunger", satiation)
