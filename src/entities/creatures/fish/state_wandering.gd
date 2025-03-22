extends CreatureState

## The speed the fish will swim around in this state.
## Will be multiplied by the creature_speed stat.
@export var speed: float = 0.5
var is_transitioning: bool = false

func enter():
	super.enter()
	is_transitioning = false
	# target_position should already be set before entering this state
	# If it's not set for some reason, set a random position
	var fish = creature as Fish
	if !fish:
		return
	if fish.target_position == Vector3.ZERO:
		fish.target_position = fish.get_random_target_position()

func exit():
	super.exit()
	is_transitioning = false


func update(delta: float):
	super.update(delta)
	
	var fish = creature as Fish
	
	# Check if the fish is hungry or starving
	if fish.hunger_bracket != CreatureData.HungerBracket.Full and not is_transitioning:
		# If hungry or starving, transition to feeding state
		is_transitioning = true
		state_transition.emit(self, "Feeding")
		return
	
	# Move towards target
	# If the target is reached, transition to idle state
	if fish.move_towards_target(delta, speed) and not is_transitioning:
		fish.target_position = fish.get_random_target_position()
