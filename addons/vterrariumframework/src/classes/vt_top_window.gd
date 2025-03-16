extends Node3D
class_name VTTopWindow

func _ready() -> void:
	VTGlobal.top_window = get_viewport().get_window()
