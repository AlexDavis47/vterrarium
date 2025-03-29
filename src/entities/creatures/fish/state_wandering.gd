extends CreatureState

## The speed the fish will swim around in this state.
## Will be multiplied by the creature_speed stat.
@export var speed: float = 1.0

func enter():
	super.enter()
	var fish = creature as Fish
	if !fish:
		return
	if fish.target_position == Vector3.ZERO:
		_set_new_target_position(fish)

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
	
	# Validate current target position before moving
	if not _is_valid_position(fish.target_position):
		_set_new_target_position(fish)
		return
	
	# Move towards target
	if fish.move_towards_target(delta, speed):
		_set_new_target_position(fish)

# New helper functions
func _set_new_target_position(fish: Fish) -> void:
	var new_pos := fish.get_random_target_position()
	if _is_valid_position(new_pos):
		fish.target_position = new_pos
	else:
		# Fallback to current position if new position is invalid
		fish.target_position = fish.global_position

func _is_valid_position(pos: Vector3) -> bool:
	return pos.is_finite() and not pos.is_zero_approx()
