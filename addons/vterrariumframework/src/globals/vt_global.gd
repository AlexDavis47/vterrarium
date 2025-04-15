extends Node

var game_world: VTGameWorld

var top_window: Window
var front_window: Window

var top_camera: VTCamera3D
var front_camera: VTCamera3D

var top_ui: TopUI
var front_ui: FrontUI

var windows_setup_completed: bool = false

var onscreen_keyboard: OnscreenKeyboard = null

var notif = preload("uid://b64q7xyp70wah")

signal windows_initialized

signal trigger_inventory_refresh

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

func display_notification(text):
	var notif_temp = notif.instantiate()
	top_window.add_child(notif_temp)
	notif_temp.display(text) 
