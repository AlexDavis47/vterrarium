extends Node

# Window references
var top_window: VTTopWindow
var front_window: VTFrontWindow
var game_world: VTGameWorld

var top_camera: VTCamera3D
var front_camera: VTCamera3D


var windows_setup_completed: bool = false
signal windows_initialized

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if not windows_setup_completed and top_window and front_window:
		setup_windows()
		windows_setup_completed = true

func setup_windows():
	windows_initialized.emit()
