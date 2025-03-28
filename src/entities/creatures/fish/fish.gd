extends Creature
class_name Fish

var target_position: Vector3

# Movement parameters
var movement_damping: float = 0.99 # Dampening factor for velocity
var rotation_force: float = 0.1
var rotation_damping: float = 0.97
var max_velocity: float = 3.0
var max_angular_velocity: float = 2.0
var upright_force: float = 0.5

var angular_velocity: Vector3 = Vector3.ZERO
var linear_velocity: Vector3 = Vector3.ZERO

var _target_marker: MeshInstance3D
var _show_target_marker: bool = false

# Only be able to eat food if the feeding cooldown is over
var _feeding_cooldown_duration: float = 5.0
var _feeding_cooldown_timer: float = 0.0
var _can_eat_food: bool = false

func _ready():
	super._ready()
	
	if _show_target_marker:
		_setup_target_marker()

func _setup_target_marker() -> void:
	_target_marker = MeshInstance3D.new()
	_target_marker.mesh = SphereMesh.new()
	_target_marker.mesh.radius = 0.1
	_target_marker.mesh.height = 0.2
	_target_marker.mesh.material = StandardMaterial3D.new()
	_target_marker.mesh.material.albedo_color = Color(1.0, 0.0, 0.0)
	add_child(_target_marker)

func _process(delta):
	if _is_in_preview_mode:
		return

	if _show_target_marker and _target_marker:
		_target_marker.global_position = target_position

	_feeding_cooldown_timer += delta
	if _feeding_cooldown_timer > _feeding_cooldown_duration:
		_feeding_cooldown_timer = _feeding_cooldown_duration
		_can_eat_food = true
	else:
		_can_eat_food = false


func set_show_target_marker(show: bool) -> void:
	if show == _show_target_marker:
		return
		
	_show_target_marker = show
	
	if _show_target_marker:
		if not _target_marker:
			_setup_target_marker()
	elif _target_marker:
		_target_marker.queue_free()
		_target_marker = null

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
func move_towards_target(delta: float, speed_multiplier: float = 1.0, switch_distance: float = 1.0) -> bool:
	# # TESTING: CANCEL ALL MOVEMENT AND TRY TRANSLATING RIGHT
	# translate(Vector3(1.0 * delta, 0.0, 0.0))
	# rotate(Vector3(1.0, 0.0, 0.0), PI * delta / 2)
	# return false
	# Apply damping to existing linear velocity
	linear_velocity *= movement_damping
	
	# Apply damping to existing angular velocity (torque)
	angular_velocity *= rotation_damping
	
	# Calculate direction to target
	var direction_to_target = (target_position - global_position).normalized()
	var distance = global_position.distance_to(target_position)
	
	# Get the fish's current forward direction
	var forward_direction = - global_transform.basis.z
	
	# Calculate the dot product to determine alignment with target
	# (1.0 = perfectly aligned, 0.0 = perpendicular, -1.0 = opposite)
	var alignment = forward_direction.dot(direction_to_target)
	var angle_factor = clamp(alignment, 0.1, 1.0) # Reduce speed when not aligned
	
	# Only apply force in the forward direction
	var happiness_factor = clamp(creature_data.creature_happiness, 0.25, 1.0)
	var speed_factor = clamp(creature_data.creature_speed, 0.25, 1.0)
	var distance_factor = clamp(distance / (switch_distance * 3.0), 0.5, 1.0)
	
	# Apply force only in the forward direction, scaled by alignment
	var force = forward_direction * speed_multiplier * speed_factor * happiness_factor * distance_factor * angle_factor * 5
	linear_velocity += force * delta
	

	# Clamp velocity to maximum
	if linear_velocity.length() > max_velocity:
		linear_velocity = linear_velocity.normalized() * max_velocity
	
	# Rotate to face target (not movement direction)
	rotate_towards_target(direction_to_target)
	
	# Keep the fish upright
	maintain_upright_orientation()
	
	# Apply angular velocity to rotation
	if angular_velocity.length() > 0.0001:
		# For rotation, we need a normalized axis and an angle
		var rotation_axis = angular_velocity.normalized()
		var rotation_angle = angular_velocity.length() * delta
		
		# Rotate the fish around the axis by the calculated angle
		rotate(rotation_axis, rotation_angle)
	
	# Apply movement to CharacterBody3D
	velocity = linear_velocity
	move_and_slide()
	
	# Check if we've reached the target
	return distance < switch_distance

## Rotates the fish to face the target direction
func rotate_towards_target(target_direction: Vector3):
	var current_forward = - global_transform.basis.z # Consistent with move_towards_target
	
	# Calculate the rotation axis and angle
	var cross_product = current_forward.cross(target_direction)
	var dot_product = current_forward.dot(target_direction)
	
	if cross_product.length_squared() > 0.001:
		cross_product = cross_product.normalized()
		# Scale torque based on how far we need to turn
		var angle_factor = clamp(1.0 - dot_product, 0.5, 1.0)
		
		# Calculate vertical difference to give priority to pitch adjustments
		var vertical_diff = abs(target_direction.y - current_forward.y)
		var vertical_emphasis = clamp(vertical_diff * 2.0, 1.0, 3.0)
		
		var torque = cross_product * rotation_force * angle_factor * vertical_emphasis
		angular_velocity += torque
		
		# Clamp angular velocity to maximum
		if angular_velocity.length() > max_angular_velocity:
			angular_velocity = angular_velocity.normalized() * max_angular_velocity

## Keeps the fish oriented correctly (upright)
func maintain_upright_orientation():
	# We want to correct roll around the fish's own forward axis
	# This will keep the dorsal fin pointing up while allowing pitch/yaw
	# Get the current up vector of the fish
	var current_up = global_transform.basis.y
	
	# The target up vector is the world up
	var target_up = Vector3(0, 1, 0)
	
	# Calculate the rotation axis (perpendicular to both vectors)
	var roll_correction_axis = current_up.cross(target_up)
	
	# Dot product tells us how aligned we are with the target up
	var up_alignment = current_up.dot(target_up)
	
	# Only apply correction if there's significant roll
	if roll_correction_axis.length_squared() > 0.001 and up_alignment < 0.99:
		roll_correction_axis = roll_correction_axis.normalized()
		
		# The more we're rolled, the stronger the correction
		var roll_correction_strength = clamp(1.0 - up_alignment, 0.0, 1.0)
		
		# Reduce upright force temporarily when fish needs to change altitude
		var forward = - global_transform.basis.z
		var to_target = (target_position - global_position).normalized()
		var vertical_adjustment = abs(to_target.y - forward.y)
		var upright_adjustment = clamp(1.0 - vertical_adjustment * 2.0, 0.2, 1.0)
		
		var roll_torque = roll_correction_axis * upright_force * roll_correction_strength * upright_adjustment
		
		angular_velocity += roll_torque
