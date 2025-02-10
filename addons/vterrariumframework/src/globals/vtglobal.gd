extends Node

# Both primary window and secondary window contain a window var
# which is the actual window object
var primary_window: PrimaryWindow
var secondary_window: SecondaryWindow

enum Screen {
	SHARED = 1,
	PRIMARY = 2,
	SECONDARY = 3
}

var shared_screen_layer: int = Screen.SHARED
var primary_screen_layer: int = Screen.PRIMARY
var secondary_screen_layer: int = Screen.SECONDARY
var windows_setup_completed: bool = false
var windows_initialized: Signal

func _ready() -> void:
	pass

func _physics_process(_delta: float) -> void:
	if not windows_setup_completed and primary_window and secondary_window:
		setup_windows()
		windows_setup_completed = true

func setup_windows():
	print("setting up")
	windows_initialized.emit()

func get_shared_screen_layer() -> int:
	return shared_screen_layer

func get_primary_screen_layer() -> int:
	return primary_screen_layer

func get_secondary_screen_layer() -> int:
	return secondary_screen_layer
