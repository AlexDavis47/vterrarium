extends CreatureState

var target_food: FishFood = null
var feeding_speed: float = 1.5 # Faster than normal wandering
var food_eat_distance: float = 1.0 # Distance at which the fish can eat the food

# Food preferences
var food_type_preferences = {
	FishFoodData.FoodType.FLAKES: 1.0 # Default preferences
}

func enter():
	super.enter()
	find_closest_food()

func exit():
	super.exit()
	target_food = null

func update(delta: float):
	super.update(delta)
	var fish = creature as Fish
	
	if not target_food or not is_instance_valid(target_food) or not target_food.is_edible or not fish._can_eat_food:
		state_transition.emit(self, "Wandering")
		return

	
	# Update target position to follow the food
	fish.target_position = target_food.global_position
	
	# If we're close enough to the food, eat it
	var distance = fish.global_position.distance_to(target_food.global_position)
	if distance < food_eat_distance:
		eat_food()
		state_transition.emit(self, "Wandering")

	# If we've reached the center target, transition to idle
	if fish.move_towards_target(delta, feeding_speed):
		state_transition.emit(self, "Wandering")
	

func find_closest_food() -> void:
	var fish = creature as Fish
	var food_items = get_tree().get_nodes_in_group("fish_food")
	var closest_distance = INF
	for food in food_items:
		if food is FishFood and food.is_edible:
			var distance = fish.global_position.distance_to(food.global_position)
			if distance < closest_distance:
				closest_distance = distance
				target_food = food
	
	
func eat_food() -> void:
	if is_instance_valid(target_food) and target_food.is_edible:
		var fish = creature as Fish
		
		# Increase satiation based on food value
		var satiation_increase = target_food.fish_food_data.food_value
		fish.creature_data.creature_satiation += satiation_increase
		
		# Let the target know it's been eaten
		target_food.eat_food()

		# Reset the feeding cooldown
		fish._feeding_cooldown_timer = 0.0
