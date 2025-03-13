extends Creature

@export var speed: float = 0.025
@export var rotation_speed: float = 5.0 # Speed at which the fish turns to face direction
@export var target_switch_distance: float = 0.1 # Distance at which to pick a new target
@export var movement_damping: float = 0.95 # Dampening factor for velocity

var target_position: Vector3
var movement_velocity: Vector3

func _ready():
	super () # Call parent _ready() function
	pick_new_target()

func _physics_process(delta):
	# Apply damping to existing velocity
	velocity *= movement_damping
	
	# Calculate movement to target
	var direction = (target_position - global_position).normalized()
	movement_velocity = direction * speed
	
	# Add movement velocity to existing velocity
	velocity += movement_velocity
	
	# Check if we've reached the target
	if global_position.distance_to(target_position) < target_switch_distance:
		pick_new_target()
	
	# Rotate to face movement direction if we're moving
	if velocity.length_squared() > 0.01:
		var target_basis = global_transform.basis.looking_at(velocity.normalized(), Vector3.UP)
		global_transform.basis = global_transform.basis.slerp(target_basis, rotation_speed * delta)
	
	move_and_slide()

func pick_new_target():
	# Get terrarium dimensions from VTConfig
	var half_width = VTConfig.width / 2
	var half_height = VTConfig.height / 2
	var half_depth = VTConfig.depth / 2
	
	# Pick a random position within the terrarium
	target_position = Vector3(
		randf_range(-half_width, half_width),
		randf_range(-half_height, half_height),
		randf_range(-half_depth, half_depth)
	)
