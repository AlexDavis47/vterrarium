extends CharacterBody3D
class_name Creature

## The creature data resource that contains all the common and savable data for the creature.
## We separate this data so that we can save and load creature data easily.
## When we remove a creature, we can just save the creature data and not the entire creature node.
## And when we load a creature, we can just load the saved data back into a new creature instance.
@export var creature_data: CreatureData

# Signals for component-related events
signal age_bracket_changed(new_bracket)
signal satiation_changed(value)
signal happiness_changed(value)

func _ready():
	add_to_group("creature")

func _physics_process(delta):
	# Process all available components
	if creature_data.hunger_data:
		_process_hunger(delta)
	
	if creature_data.age_data:
		_process_age(delta)
	
	if creature_data.happiness_data:
		_process_happiness(delta)

# --- Age processing ---
func _process_age(delta):
	var age_data = creature_data.age_data
	
	# Store previous age bracket
	var previous_bracket = age_data.get_age_bracket()
	
	# Update age
	age_data.age.base_value += delta
	
	# Check for age bracket changes
	var current_bracket = age_data.get_age_bracket()
	if current_bracket != previous_bracket:
		emit_signal("age_bracket_changed", current_bracket)

# --- Hunger processing ---
func _process_hunger(delta):
	var hunger_data = creature_data.hunger_data
	
	# Decrease satiation over time based on hunger_rate
	# Delta is converted from seconds to hours for the calculation
	var new_satiation = hunger_data.satiation.modified_value - hunger_data.hunger_rate.modified_value * (delta / 3600.0)
	hunger_data.satiation.modified_value = clamp(new_satiation, 0.0, 1.0)
	
	# Update the happiness modifier with the new satiation value
	if creature_data.happiness_data:
		creature_data.happiness_data.base_happiness.set_modifier("Hunger", hunger_data.satiation.modified_value)
	
	# Emit signal for UI updates
	emit_signal("satiation_changed", hunger_data.satiation.modified_value)
	
	# Check for food
	var closest_food = find_closest_food()
	if closest_food and global_position.distance_to(closest_food.global_position) < 0.5:
		eat_food(closest_food)

# --- Happiness processing ---
func _process_happiness(delta):
	var happiness_data = creature_data.happiness_data
	var current_happiness = happiness_data.get_current_happiness()
	
	# Emit signal for UI updates if happiness changed
	emit_signal("happiness_changed", current_happiness)

# --- Helper functions ---
func find_closest_food() -> FishFood:
	var closest_food = null
	var closest_distance = 1000000
	for food in get_tree().get_nodes_in_group("fish_food"):
		var distance = global_position.distance_to(food.global_position)
		if distance < closest_distance:
			closest_distance = distance
			closest_food = food
	return closest_food

func eat_food(food: FishFood) -> void:
	if food.is_edible:
		food.eat_food()
		print("Eating food")
		creature_data.hunger_data.satiation.modified_value += food.fish_food_data.food_value
		creature_data.hunger_data.satiation.modified_value = clamp(creature_data.hunger_data.satiation.modified_value, 0.0, 1.0)
		emit_signal("satiation_changed", creature_data.hunger_data.satiation.modified_value)
