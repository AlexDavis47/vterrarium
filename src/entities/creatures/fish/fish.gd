extends Creature
class_name Fish

var target_position: Vector3

# Movement parameters
var movement_damping: float = 0.99 # Dampening factor for velocity
var rotation_force: float = 0.00001
var rotation_damping: float = 0.99
var max_velocity: float = 3.0
var max_angular_velocity: float = 2.0
var upright_force: float = 0.5
var target_switch_distance: float = 1.0

var angular_velocity: Vector3 = Vector3.ZERO
var linear_velocity: Vector3 = Vector3.ZERO

func _ready():
	super._ready()

## For wandering fish.
func get_random_target_position() -> Vector3:
	# Get terrarium dimensions from VTConfig
	var half_width = VTConfig.width / 2
	var half_height = VTConfig.height / 2
	var half_depth = VTConfig.depth / 2
	
	var pos: Vector3
	# Pick a random position within the terrarium
	pos = Vector3(
		randf_range(-half_width + 1.0, half_width - 1.0),
		randf_range(-half_height + 1.0, half_height - 1.0),
		randf_range(-half_depth + 1.0, half_depth - 1.0)
	)
	return pos

## Moves the fish towards the target position
func move_towards_target(delta: float, speed_multiplier: float = 1.0) -> bool:
	# Apply damping to existing linear velocity
	linear_velocity *= movement_damping
	
	# Apply damping to existing angular velocity (torque)
	angular_velocity *= rotation_damping
	
	# Calculate movement to target
	var direction = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)
	
	# Scale force based on distance to slow down as we approach the target
	var distance_factor = clamp(distance / (target_switch_distance * 3.0), 0.1, 1.0)
	
	# Apply force in the direction of the target
	var force = direction * speed_multiplier * creature_data.creature_speed * distance_factor * creature_data.creature_happiness * 10
	linear_velocity += force * delta
	
	# Clamp velocity to maximum
	if linear_velocity.length() > max_velocity:
		linear_velocity = linear_velocity.normalized() * max_velocity
	
	# Rotate to face movement direction if we're moving
	if linear_velocity.length_squared() > 0.01:
		face_movement_direction()
	
	# Keep the fish upright
	maintain_upright_orientation()
	
	# Apply movement to CharacterBody3D
	velocity = linear_velocity
	move_and_slide()
	
	# Check if we've reached the target
	return distance < target_switch_distance

## Rotates the fish to face the direction it's moving
func face_movement_direction():
	var current_forward = - global_transform.basis.z
	var target_forward = linear_velocity.normalized()
	
	# Calculate the rotation axis and angle
	var cross_product = current_forward.cross(target_forward)
	var dot_product = current_forward.dot(target_forward)
	
	if cross_product.length_squared() > 0.001:
		cross_product = cross_product.normalized()
		# Scale torque based on how far we need to turn
		var angle_factor = clamp(1.0 - dot_product, 0.5, 1.0)
		var torque = cross_product * rotation_force * angle_factor
		angular_velocity += torque
		
		# Clamp angular velocity to maximum
		if angular_velocity.length() > max_angular_velocity:
			angular_velocity = angular_velocity.normalized() * max_angular_velocity

## Keeps the fish oriented correctly (upright)
func maintain_upright_orientation():
	var current_up = global_transform.basis.y
	var desired_up = Vector3.UP
	var upright_cross = current_up.cross(desired_up)
	
	if upright_cross.length_squared() > 0.001:
		upright_cross = upright_cross.normalized()
		var upright_dot = current_up.dot(desired_up)
		var upright_angle_factor = clamp(1.0 - upright_dot, 0.0, 1.0)
		var upright_torque = upright_cross * upright_force * upright_angle_factor
		angular_velocity += upright_torque
