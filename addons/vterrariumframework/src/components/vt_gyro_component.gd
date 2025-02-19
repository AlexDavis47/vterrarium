extends Node
class_name VTGyroComponent
## This component will receive the gyro information from the hardware global and apply it to the parent entity

# TODO: WE SHOULD NOT BE APPLYING FORCES TO THE PARENT NODE DIRECTLY, WE SHOULD CREATE A NEW VTMovementComponent
# that will contain velocity and acceleration variables and apply them to the parent node


# Reference to parent node that we'll be manipulating
var parent_node: Node3D

# Enable/disable entire component
@export var enabled: bool = true

# Individual influence multipliers (0-1)
@export_range(0.0, 1.0) var rotation_influence: float = 1.0
@export_range(0.0, 1.0) var acceleration_influence: float = 1.0
@export_range(0.0, 2.0) var distance_multiplier: float = 1.0  # How much distance from center affects force

# Enable/disable specific rotation axes
@export_group("Rotation Axes")
@export var rotate_x: bool = true
@export var rotate_y: bool = true
@export var rotate_z: bool = true

# Enable/disable specific movement axes
@export_group("Movement Axes")
@export var move_x: bool = true
@export var move_y: bool = true
@export var move_z: bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	# Get parent node and ensure it's a Node3D
	parent_node = get_parent()
	if not parent_node is Node3D:
		push_error("VTGyroComponent: Parent node must be a Node3D")
		return
		
	# Connect to hardware signals
	VTHardware.gyro_rotation_delta_changed.connect(_on_gyro_rotation_delta_changed)
	VTHardware.gyro_acceleration_changed.connect(_on_gyro_acceleration_changed)

func _on_gyro_rotation_delta_changed(rotation_delta: Vector3) -> void:
	if not enabled or not parent_node:
		return
		
	# Filter rotation axes and apply influence
	var filtered_rotation = Vector3(
		rotation_delta.x if rotate_x else 0.0,
		rotation_delta.y if rotate_y else 0.0,
		rotation_delta.z if rotate_z else 0.0
	)
	
	# Apply rotation based on inverse viscosity (higher viscosity = less rotation)
	var viscosity = VTConfig.viscosity
	var viscosity_factor = 1.0 - viscosity  # Invert the viscosity effect
	
	# Create a rotation transform from the delta angles
	var rotation_transform = Transform3D()
	rotation_transform = rotation_transform.rotated(Vector3.RIGHT, filtered_rotation.x * viscosity_factor * rotation_influence)
	rotation_transform = rotation_transform.rotated(Vector3.UP, filtered_rotation.y * viscosity_factor * rotation_influence)
	rotation_transform = rotation_transform.rotated(Vector3.FORWARD, filtered_rotation.z * viscosity_factor * rotation_influence)
	
	# Apply the rotation transform to the current rotation
	parent_node.transform.basis = rotation_transform.basis * parent_node.transform.basis
	
	# Calculate tangential velocity from rotation
	var distance_to_center = parent_node.global_position.length()
	var distance_factor = distance_to_center * distance_multiplier
	
	# Calculate tangential velocity based on rotation delta and distance
	var tangential_velocity = Vector3.ZERO
	
	if rotate_x:
		# Rotation around X affects Y and Z movement
		tangential_velocity += Vector3(0, 
			-rotation_delta.x * parent_node.global_position.z,
			rotation_delta.x * parent_node.global_position.y)
	
	if rotate_y:
		# Rotation around Y affects X and Z movement
		tangential_velocity += Vector3(
			rotation_delta.y * parent_node.global_position.z,
			0,
			-rotation_delta.y * parent_node.global_position.x)
	
	if rotate_z:
		# Rotation around Z affects X and Y movement
		tangential_velocity += Vector3(
			-rotation_delta.z * parent_node.global_position.y,
			rotation_delta.z * parent_node.global_position.x,
			0)
	
	# Apply the tangential velocity with distance scaling and inverse viscosity
	if parent_node is RigidBody3D:
		parent_node.apply_central_force(tangential_velocity * viscosity_factor * distance_factor)
	elif parent_node is CharacterBody3D:
		parent_node.velocity += tangential_velocity * viscosity_factor * distance_factor

func _on_gyro_acceleration_changed(new_acceleration: Vector3) -> void:
	if not enabled or not parent_node:
		return
		
	# Filter movement axes
	var filtered_acceleration = Vector3(
		new_acceleration.x if move_x else 0.0,
		new_acceleration.y if move_y else 0.0,
		new_acceleration.z if move_z else 0.0
	)
	
	# Calculate distance-based scaling
	var distance_to_center = parent_node.global_position.length()
	var distance_factor = distance_to_center * distance_multiplier
	
	# Apply acceleration based on inverse viscosity (higher viscosity = less movement)
	var viscosity = VTConfig.viscosity
	var viscosity_factor = 1.0 - viscosity  # Invert the viscosity effect
	var final_acceleration = filtered_acceleration * viscosity_factor * acceleration_influence * distance_factor
	
	# If the parent is a physics body, apply force
	if parent_node is RigidBody3D:
		parent_node.apply_central_force(final_acceleration)
	elif parent_node is CharacterBody3D:
		parent_node.velocity += final_acceleration

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
