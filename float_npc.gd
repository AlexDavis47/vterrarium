extends CharacterBody3D

@export var bounds_min: Vector3 = Vector3(-5, -5, -5)
@export var bounds_max: Vector3 = Vector3(5, 5, 5)
@export var speed: float = 2.0
@export var mesh1: MeshInstance3D
@export var mesh2: MeshInstance3D

var target_position: Vector3

func _ready():
	randomize()
	randomize_color()
	pick_new_target()

func _process(delta):
	move_towards_target(delta)

func pick_new_target():
	target_position = Vector3(
		randf_range(bounds_min.x, bounds_max.x),
		randf_range(bounds_min.y, bounds_max.y),
		randf_range(bounds_min.z, bounds_max.z)
	)

func move_towards_target(delta):
	var direction = (target_position - global_transform.origin).normalized()
	velocity = direction * speed

	if global_transform.origin.distance_to(target_position) < 0.5:
		pick_new_target()

	move_and_slide()
	
func randomize_color():
	# Create new materials to ensure uniqueness
	var mat1 = StandardMaterial3D.new()
	var mat2 = StandardMaterial3D.new()
	var color: Color = Color(randf(), randf(), randf(), 1)

	# Assign unique random colors
	mat1.albedo_color = color
	mat2.albedo_color = color

	# Ensure each instance gets a unique mesh copy
	mesh1.mesh = mesh1.mesh.duplicate(true)
	mesh2.mesh = mesh2.mesh.duplicate(true)

	# Assign the new materials to the newly duplicated meshes
	mesh1.set_surface_override_material(0, mat1)
	mesh2.set_surface_override_material(0, mat2)
