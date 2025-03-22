extends CreatureState

var idle_timer: SceneTreeTimer = null
var min_idle_time: float = 0.5
var max_idle_time: float = 4.0
var is_transitioning: bool = false

func enter():
	super.enter()
	is_transitioning = false
	# Start the idle timer
	var wait_time = randf_range(min_idle_time, max_idle_time)
	idle_timer = get_tree().create_timer(wait_time)
	idle_timer.timeout.connect(_on_idle_timer_timeout)

func exit():
	super.exit()
	is_transitioning = false
	# Disconnect the timer if it still exists
	if idle_timer and idle_timer.timeout.is_connected(_on_idle_timer_timeout):
		idle_timer.timeout.disconnect(_on_idle_timer_timeout)

func update(delta: float):
	super.update(delta)
	
	var fish = creature as Fish
	
	# Check if the fish is hungry or starving
	if fish.hunger_bracket != CreatureData.HungerBracket.Full and not is_transitioning:
		# If hungry or starving, transition to feeding state
		is_transitioning = true
		state_transition.emit(self, "Feeding")

func _on_idle_timer_timeout():
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
			var wait_time = randf_range(min_idle_time, max_idle_time)
			idle_timer = get_tree().create_timer(wait_time)
			idle_timer.timeout.connect(_on_idle_timer_timeout)
	# If fish is hungry, we'll transition in the update method
