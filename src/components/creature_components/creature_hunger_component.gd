## Component that manages creature hunger and satiation
##
## This component handles:
## - Tracking the creature's satiation level (fullness)
## - Decreasing satiation over time (hunger)
## - Updating happiness based on hunger level
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
		satiation = clamp(value, 0.0, 1.0)
		emit_signal("satiation_changed", value)

## The rate per hour at which the creature will lose satiation.
## Higher values make the creature get hungry faster
@export var hunger_rate: float = 1.0

## Initialize the hunger component and set up modifiers
func _ready() -> void:
	super()
	# Set up a happiness modifier based on hunger
	var happiness = creature.creature_data.creature_happiness
	# When satiation is high, happiness is maximized (multiplied by 1.0)
	# When satiation is low, happiness is reduced (multiplied by a lower value)
	creature.creature_data.creature_happiness.add_modifier("Hunger", satiation, happiness.MODIFIER_MULTIPLY)
	creature.creature_data.creature_happiness.set_modifier_enabled("Hunger", true)

## Update the satiation level and related modifiers
func _physics_process(delta: float) -> void:
	# Decrease satiation over time based on hunger_rate
	# Delta is converted from seconds to hours for the calculation
	satiation -= hunger_rate * (delta / 3600.0)
	
	# Update the happiness modifier with the new satiation value
	creature.creature_data.creature_happiness.set_modifier("Hunger", satiation)


	if find_closest_food() != null:
		if creature.global_position.distance_to(find_closest_food().global_position) < 1:
			eat_food(find_closest_food())
			

## Find the closest food to the creature and return it
func find_closest_food() -> FishFood:
	var closest_food = null
	var closest_distance = 1000000
	for food in get_tree().get_nodes_in_group("fish_food"):
		var distance = creature.global_position.distance_to(food.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_food = food
	return closest_food

## Eat the closest food to the creature and increase satiation
func eat_food(food: FishFood) -> void:
	if food.is_edible:
		food.eat_food()
		print("Eating food")
		satiation += food.fish_food_data.food_value
