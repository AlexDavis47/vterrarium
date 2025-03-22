extends CreatureState

var target_food: FishFood = null
var feeding_speed: float = 1.0 # Faster than normal wandering
var food_eat_distance: float = 1.0 # Distance at which the fish can eat the food
var is_transitioning: bool = false
var is_post_feeding: bool = false # Flag for the post-feeding phase

func enter():
	super.enter()
	is_transitioning = false
	is_post_feeding = false
	find_closest_food()

func exit():
	super.exit()
	is_transitioning = false
	is_post_feeding = false
	target_food = null

func update(delta: float):
	super.update(delta)
	
	var fish = creature as Fish
	
	# Handle post-feeding phase
	if is_post_feeding:
		# If we've reached the center target, transition to idle
		if fish.move_towards_target(delta, feeding_speed * 0.5) and not is_transitioning:
			is_transitioning = true
			state_transition.emit(self, "Idle")
		return
	
	# No food found or food is no longer available, go back to idle
	if (not is_instance_valid(target_food) or not target_food.is_edible) and not is_transitioning:
		set_center_target(fish)
		is_post_feeding = true
		return
	
	# Update target position to follow the food
	fish.target_position = target_food.global_position
	
	# If we're close enough to the food, eat it
	var distance = fish.global_position.distance_to(target_food.global_position)
	if distance < food_eat_distance and not is_transitioning:
		eat_food()
		set_center_target(fish)
		is_post_feeding = true

func _physics_process(delta):
	var fish = creature as Fish
	
	# Skip if in post-feeding phase (handled in update)
	if is_post_feeding:
		return
	
	# If the target is reached
	if is_instance_valid(target_food) and fish.move_towards_target(delta, feeding_speed) and not is_transitioning:
		eat_food()
		set_center_target(fish)
		is_post_feeding = true

# Set a target position above and towards center of tank
func set_center_target(fish: Fish):
	# Get current position
	var current_pos = fish.global_position
	
	# Get center of tank
	var center_x: float = 0
	var center_z: float = 0
	
	# Calculate a position that's between current position and center, but higher up
	var target_x = lerp(current_pos.x, center_x, 0.3)
	var target_z = lerp(current_pos.z, center_z, 0.3)
	
	# Set y position higher than current to avoid floor
	var target_y = current_pos.y + 3.0
	
	# Set the new target
	fish.target_position = Vector3(target_x, target_y, target_z)

func find_closest_food() -> void:
	var fish = creature as Fish
	var food_items = get_tree().get_nodes_in_group("fish_food")
	
	if food_items.size() > 0:
		var closest_distance = INF
		var closest_food = null
		
		for food in food_items:
			if food is FishFood and food.is_edible:
				var distance = fish.global_position.distance_to(food.global_position)
				if distance < closest_distance:
					closest_distance = distance
					closest_food = food
		
		if closest_food:
			target_food = closest_food
			fish.target_position = target_food.global_position
		else:
			# No edible food found, go back to center then idle
			set_center_target(fish)
			is_post_feeding = true
	else:
		# No food found, go back to center then idle
		set_center_target(fish)
		is_post_feeding = true

func eat_food() -> void:
	if is_instance_valid(target_food) and target_food.is_edible:
		var fish = creature as Fish
		# Increase satiation based on food value
		fish.creature_data.creature_satiation += target_food.fish_food_data.food_value
		# Tell the food it was eaten
		target_food.eat_food()
