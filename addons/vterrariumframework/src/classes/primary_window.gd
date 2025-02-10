extends Node3D
class_name PrimaryWindow

var window : Window

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	window = get_viewport().get_window()
	VTGlobal.primary_window = self

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
