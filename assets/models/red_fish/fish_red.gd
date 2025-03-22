extends Node3D

# Movement parameters
var movement_damping: float = 0.99
var rotation_force: float = 0.01
var rotation_damping: float = 0.99
var max_velocity: float = 5.0
var max_angular_velocity: float = 2.0
var upright_force: float = 0.5
var target_switch_distance: float = 0.5
var target_position: Vector3
var velocity: Vector3 = Vector3.ZERO
var angular_velocity: Vector3 = Vector3.ZERO

# Swimming wiggle parameters
var wiggle_amplitude: float = 2.2
var wiggle_frequency: float = 10.0
var wiggle_time: float = 0.0

func _ready() -> void:
	# Set initial target position
	target_position = get_random_target_position()
	# Create timer for target position updates
	var movement_timer := Timer.new()
	add_child(movement_timer)
	movement_timer.wait_time = 2.0
	movement_timer.timeout.connect(_update_target_position)
	movement_timer.start()

func _physics_process(delta: float) -> void:
	move_towards_target(delta)
	
	# Apply movement
	global_position += velocity * delta
	
	# Apply rotation
	var rotation_change = angular_velocity * delta
	rotate_x(rotation_change.x)
	rotate_y(rotation_change.y)
	rotate_z(rotation_change.z)
	
	# Apply swimming wiggle motion
	apply_swimming_wiggle(delta)
	
	# Apply damping
	velocity *= movement_damping
	angular_velocity *= rotation_damping

func apply_swimming_wiggle(delta: float) -> void:
	return
	# Only wiggle when moving
	if velocity.length_squared() > 0.1:
		wiggle_time += delta
		# Calculate wiggle based on sine wave
		var wiggle_strength = sin(wiggle_time * wiggle_frequency) * wiggle_amplitude * delta
		
		# Apply wiggle perpendicular to movement direction
		# Use the fish's local right vector (x-axis) for side-to-side motion
		var wiggle_direction = transform.basis.x.normalized()
		
		# Translate the fish along this direction
		# global_position += wiggle_direction * wiggle_strength
		
		# Also add a slight rotation for more natural movement
		rotate(transform.basis.y.normalized(), wiggle_strength * 0.2)

func _update_target_position() -> void:
	target_position = get_random_target_position()

## For wandering fish.
func get_random_target_position() -> Vector3:
	# Get terrarium dimensions from VTConfig
	var half_width = VTConfig.terrarium_dimensions.x / 2.0
	var half_height = VTConfig.terrarium_dimensions.y / 2.0
	var half_depth = VTConfig.terrarium_dimensions.z / 2.0
	
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
	# Calculate movement to target
	var direction = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)
	
	# Scale force based on distance to slow down as we approach the target
	var distance_factor = clamp(distance / (target_switch_distance * 3.0), 0.1, 1.0)
	
	# Apply force in the direction of the target
	var force = direction * speed_multiplier * 5.0 * distance_factor
	velocity += force * delta
	
	# Clamp velocity to maximum
	if velocity.length() > max_velocity:
		velocity = velocity.normalized() * max_velocity
	
	# Rotate to face movement direction if we're moving
	if velocity.length_squared() > 0.01:
		face_movement_direction()
	
	# Keep the fish upright
	maintain_upright_orientation()
	
	# Check if we've reached the target
	if distance < target_switch_distance:
		target_position = get_random_target_position()
		return true
	return false

## Rotates the fish to face the direction it's moving
func face_movement_direction():
	var current_forward = -global_transform.basis.z
	var target_forward = velocity.normalized()
	
	# Calculate the rotation axis and angle
	var cross_product = current_forward.cross(target_forward)
	var dot_product = current_forward.dot(target_forward)
	
	if cross_product.length_squared() > 0.001:
		cross_product = cross_product.normalized()
		# Scale torque based on how far we need to turn
		var angle_factor = clamp(1.0 - dot_product, 0.5, 1.0)
		var torque = cross_product * rotation_force * angle_factor
		angular_velocity += torque

## Keeps the fish oriented correctly (upright)
func maintain_upright_orientation():
	return
	var current_up = global_transform.basis.y
	var desired_up = Vector3.UP
	var upright_cross = current_up.cross(desired_up)
	
	if upright_cross.length_squared() > 0.001:
		upright_cross = upright_cross.normalized()
		var upright_dot = current_up.dot(desired_up)
		var upright_angle_factor = clamp(1.0 - upright_dot, 0.0, 1.0)
		var upright_torque = upright_cross * upright_force * upright_angle_factor
		angular_velocity += upright_torque
