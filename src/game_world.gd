extends Node3D

@export var terrarium_mesh: MeshInstance3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	VTConfig.terrarium_dimensions_changed.connect(_on_config_dimensions_changed)
	_on_config_dimensions_changed(VTConfig.width, VTConfig.height, VTConfig.depth)


func _on_config_dimensions_changed(width: float, height: float, depth: float) -> void:
	terrarium_mesh.mesh.size = Vector3(width, height, depth)
	print("terrarium_mesh.mesh.size: ", terrarium_mesh.mesh.size)
