extends Node

var game_world: VTGameWorld

var top_window: Window
var front_window: Window

var top_camera: VTCamera3D
var front_camera: VTCamera3D

var windows_setup_completed: bool = false
signal windows_initialized

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	print("top window: " + str(top_window))
	print("front window: " + str(front_window))

func _physics_process(_delta: float) -> void:
	if not windows_setup_completed and top_camera and front_camera:
		setup_windows()
		windows_setup_completed = true

func setup_windows():
	windows_initialized.emit()
