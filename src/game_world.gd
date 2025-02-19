extends Node3D
class_name VTGameWorld

@export var terrarium_mesh: MeshInstance3D
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	VTGlobal.game_world = self
	VTConfig.terrarium_dimensions_changed.connect(_on_config_dimensions_changed)
	_on_config_dimensions_changed(VTConfig.width, VTConfig.height, VTConfig.depth)


func _on_config_dimensions_changed(width: float, height: float, depth: float) -> void:
	terrarium_mesh.mesh.size = Vector3(width, height, depth)
	print("terrarium_mesh.mesh.size: ", terrarium_mesh.mesh.size)
