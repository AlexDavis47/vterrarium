extends Fish

# Override movement parameters for simpler movement
var movement_speed: float = 0.5
var rotation_speed: float = 2.0

# Override the move_towards_target function for simpler movement
func move_towards_target(delta: float, speed_multiplier: float = 1.0, switch_distance: float = 1.0) -> bool:
	if _is_in_preview_mode:
		return false
	
	# Calculate direction to target
	var direction_to_target = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)
	
	# Only rotate on Y axis for horizontal movement
	var current_forward = - global_transform.basis.z
	var target_direction = Vector3(direction_to_target.x, 0, direction_to_target.z).normalized()
	
	# Calculate angle between current and target direction
	var angle = current_forward.signed_angle_to(target_direction, Vector3.UP)
	
	# Rotate towards target
	if abs(angle) > 0.01:
		var rotation_amount = sign(angle) * min(abs(angle), rotation_speed * delta)
		rotate_y(rotation_amount)
	
	# Apply creature data modifiers to movement
	var happiness_factor = clamp(creature_data.creature_happiness, 0.25, 1.0)
	var speed_factor = clamp(creature_data.creature_speed, 0.25, 1.0)
	
	# Calculate movement in all directions
	var horizontal_movement = - global_transform.basis.z * movement_speed * speed_multiplier * speed_factor * happiness_factor * delta
	
	# Add vertical movement component
	var vertical_diff = target_position.y - global_position.y
	var vertical_movement = Vector3(0, sign(vertical_diff) * movement_speed * speed_multiplier * speed_factor * happiness_factor * delta, 0)
	
	# Combine movements
	global_position += horizontal_movement + vertical_movement
	
	# Check if we've reached the target
	return distance < switch_distance

# Override these functions to do nothing since we don't need them
func rotate_towards_target(_target_direction: Vector3):
	pass

func maintain_upright_orientation():
	pass
