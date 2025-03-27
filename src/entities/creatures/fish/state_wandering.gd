extends CreatureState

## The speed the fish will swim around in this state.
## Will be multiplied by the creature_speed stat.
@export var speed: float = 1.0

func enter():
	super.enter()
	# target_position should already be set before entering this state
	# If it's not set for some reason, set a random position
	var fish = creature as Fish
	if !fish:
		return
	if fish.target_position == Vector3.ZERO:
		fish.target_position = fish.get_random_target_position()

func exit():
	super.exit()


func update(delta: float):
	super.update(delta)
	
	var fish = creature as Fish
	
	# Check if the fish is hungry or starving
	if fish.creature_data.creature_hunger_bracket != CreatureData.HungerBracket.Full and fish.find_closest_food() and fish._can_eat_food:
		# If hungry or starving, transition to feeding state
		state_transition.emit(self, "Feeding")
		return
	
	# Move towards target
	if fish.move_towards_target(delta, speed):
		fish.target_position = fish.get_random_target_position()
