extends CreatureState

var min_idle_time: float = 0.5
var max_idle_time: float = 4.0
var is_transitioning: bool = false
var idle_time_counter: float = 0.0
var current_idle_duration: float = 0.0

func enter():
	super.enter()
	is_transitioning = false
	# Set up the idle duration
	idle_time_counter = 0.0
	current_idle_duration = randf_range(min_idle_time, max_idle_time)

func exit():
	super.exit()
	is_transitioning = false

func update(delta: float):
	super.update(delta)
	var fish = creature as Fish
	fish.target_position = fish.get_random_target_position()
	state_transition.emit(self, "Wandering")
	return
	# Check if the fish is hungry or starving
	if fish.hunger_bracket != CreatureData.HungerBracket.Full and not is_transitioning:
		# If hungry or starving, transition to feeding state
		is_transitioning = true
		state_transition.emit(self, "Feeding")
	
	# Update idle time counter
	idle_time_counter += delta
	
	# Check if idle time is complete
	if idle_time_counter >= current_idle_duration and not is_transitioning:
		_on_idle_time_complete()

func _on_idle_time_complete():
	var fish = creature as Fish
	
	# If fish is not hungry, randomly decide to wander
	if fish.hunger_bracket == CreatureData.HungerBracket.Full and not is_transitioning:
		# 50% chance to go wandering
		if randf() > 0.5:
			is_transitioning = true
			fish.target_position = fish.get_random_target_position()
			state_transition.emit(self, "Wandering")
		else:
			# Stay idle for a bit longer
			idle_time_counter = 0.0
			current_idle_duration = randf_range(min_idle_time, max_idle_time)
	# If fish is hungry, we'll transition in the update method
