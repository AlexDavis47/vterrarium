extends Node3D
class_name VTGameWorld

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	VTGlobal.game_world = self
