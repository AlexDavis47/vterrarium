extends CharacterBody3D

@export var speed: float = 0.025
@export var sprite1: Sprite3D
@export var sprite2: Sprite3D
@export var rotation_speed: float = 5.0 # Speed at which it turns to face direction
@export var velocity_dampening: float = 0.95 # How quickly velocity from external sources decays

var target_position: Vector3
var initial_forward = Vector3(0, 0, -1) # Default facing direction (-Z)
var movement_velocity: Vector3 # Stores our intentional movement velocity

func _ready():
	randomize()
	randomize_color()
	pick_new_target()

func _physics_process(delta):
	# Apply dampening to existing velocity (from external sources)
	velocity *= velocity_dampening
	
	# Add our movement velocity
	move_towards_target(delta)
	
	# Only rotate if we're actually moving
	if velocity.length_squared() > 0.01:
		# Calculate the target rotation to face the movement direction
		var target_transform = Transform3D()
		target_transform = target_transform.looking_at(velocity.normalized(), Vector3.UP)
		
		# Smoothly interpolate current rotation to target rotation
		global_transform.basis = global_transform.basis.slerp(
			target_transform.basis,
			rotation_speed * delta
		)
	
	move_and_slide()

func pick_new_target():
	target_position = Vector3(
		randf_range(-VTConfig.width / 2, VTConfig.width / 2),
		randf_range(-VTConfig.height / 2, VTConfig.height / 2),
		randf_range(-VTConfig.depth / 2, VTConfig.depth / 2)
	)

func move_towards_target(delta):
	var direction = (target_position - global_transform.origin).normalized()
	movement_velocity = direction * speed
	
	# Add our movement velocity to existing velocity
	velocity += movement_velocity
	
	if global_transform.origin.distance_to(target_position) < 0.01:
		pick_new_target()

func randomize_color():
	var new_color = Color(randf(), randf(), randf(), 1.0)
	if sprite1:
		sprite1.modulate = new_color
	if sprite2:
		sprite2.modulate = new_color
