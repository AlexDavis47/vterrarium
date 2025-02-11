extends Node

# Window references
var primary_window: Window
var secondary_window: Window

# Terrarium dimensions
@export var height: float = 10.0
@export var width: float = 5.625
@export var depth: float = 5.625

signal fov_changed(new_fov: float)

# Camera configuration
var _horizontal_fov_deg: float = 45.0
@export var horizontal_fov_deg: float:
	get:
		return _horizontal_fov_deg
	set(value):
		_horizontal_fov_deg = value
		fov_changed.emit(value)

@export var aspect_ratio_magic_number: float = 2.52 # 16/9

# Screen layer configuration
enum Screen {
	SHARED = 1,
	TOP = 2,
	FRONT = 3
}

var shared_screen_layer: int = Screen.SHARED
var top_screen_layer: int = Screen.TOP
var front_screen_layer: int = Screen.FRONT

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	primary_window = get_viewport().get_window()
	secondary_window = get_viewport().get_window()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func get_shared_screen_layer() -> int:
	return shared_screen_layer

func get_top_screen_layer() -> int:
	return top_screen_layer

func get_front_screen_layer() -> int:
	return front_screen_layer
