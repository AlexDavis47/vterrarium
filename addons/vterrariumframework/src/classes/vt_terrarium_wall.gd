extends MeshInstance3D
class_name VTTerrariumWall

## Represents a wall in the VTerrarium that can be placed on any side.
## Each wall is a plane mesh positioned at the terrarium boundaries.

enum WallType {
	RIGHT, # = Collision Mask Layer 25
	LEFT, # = Collision Mask Layer 26
	TOP, # = Collision Mask Layer 27
	BOTTOM, # = Collision Mask Layer 28
	FRONT, # = Collision Mask Layer 29
	BACK # = Collision Mask Layer 30
}

@export var static_body: StaticBody3D ## Generated static body for the wall
@export var collision_shape: CollisionShape3D ## Generated collision shape for the wall


# Store information like which type of wall it is. Exported to allow for editing in the inspector.
@export var wall_type: WallType = WallType.RIGHT:
	set(value):
		wall_type = value
		_update_wall()

func _ready() -> void:
	# Connect to terrarium dimension changes
	VTConfig.terrarium_dimensions_changed.connect(_on_terrarium_dimensions_changed)
	
	# Initial setup
	_update_wall()

## Updates the wall's dimensions and position based on the wall type
func _update_wall() -> void:
	var plane_mesh := PlaneMesh.new()
	var current_material = null
	if mesh:
		current_material = mesh.surface_get_material(0)
	
	var half_width: float = VTConfig.width / 2.0
	var half_height: float = VTConfig.height / 2.0
	var half_depth: float = VTConfig.depth / 2.0
	
	# Set dimensions and position based on wall type
	# Remember: Plane mesh starts facing up (+Y), we need to rotate accordingly
	# All faces should point inward toward the center (0,0,0)
	match wall_type:
		WallType.RIGHT:
			plane_mesh.size = Vector2(VTConfig.height, VTConfig.depth)
			position = Vector3(half_width, 0, 0)
			# Rotate from up (+Y) to face left (-X) (inward)
			rotation_degrees = Vector3(0, 0, 90)
			_generate_static_body(25)

		WallType.LEFT:
			plane_mesh.size = Vector2(VTConfig.height, VTConfig.depth)
			position = Vector3(- half_width, 0, 0)
			# Rotate from up (+Y) to face right (+X) (inward)
			rotation_degrees = Vector3(0, 0, -90)
			_generate_static_body(26)
			
		WallType.TOP:
			plane_mesh.size = Vector2(VTConfig.width, VTConfig.depth)
			position = Vector3(0, half_height, 0)
			# Rotate from up (+Y) to face down (-Y) (inward)
			rotation_degrees = Vector3(180, 0, 0)
			_generate_static_body(27)

		WallType.BOTTOM:
			plane_mesh.size = Vector2(VTConfig.width, VTConfig.depth)
			position = Vector3(0, - half_height, 0)
			# Already facing up (+Y) (inward)
			rotation_degrees = Vector3(0, 0, 0)
			_generate_static_body(28)

		WallType.FRONT:
			plane_mesh.size = Vector2(VTConfig.width, VTConfig.height)
			position = Vector3(0, 0, half_depth)
			# Rotate from up (+Y) to face back (+Z) (inward)
			rotation_degrees = Vector3(-90, 0, 0)
			_generate_static_body(29)

		WallType.BACK:
			plane_mesh.size = Vector2(VTConfig.width, VTConfig.height)
			position = Vector3(0, 0, - half_depth)
			# Rotate from up (+Y) to face front (-Z) (inward)
			rotation_degrees = Vector3(90, 0, 0)
			_generate_static_body(30)

	mesh = plane_mesh
	if current_material:
		mesh.surface_set_material(0, current_material)


func _generate_static_body(layer: int) -> void:
	if not static_body:
		static_body = StaticBody3D.new()
		collision_shape = CollisionShape3D.new()
		static_body.add_child(collision_shape)
		add_child(static_body)
	# Create a collision shape based on the plane mesh
	mesh.create_trimesh_shape()
	collision_shape.shape = mesh.create_trimesh_shape()
	static_body.collision_layer = 0 # Reset layers
	static_body.set_collision_layer_value(1, true)
	static_body.set_collision_layer_value(layer, true)


## Called when the terrarium dimensions change
func _on_terrarium_dimensions_changed(_width: float, _height: float, _depth: float) -> void:
	_update_wall()
