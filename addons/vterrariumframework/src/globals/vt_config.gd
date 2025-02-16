extends Node

# Signals
signal fov_changed(new_fov: float)
signal terrarium_dimensions_changed(new_width: float, new_height: float, new_depth: float)

# Terrarium dimensions
# TODO: Due to the fact that we are using a fixed vertical FOV, if the height and depth are set to be less than 16/9,
# then the cameras will be able to view outside of the terrarium.
@export var width: float = 10.0:
	set(value):
		width = value
		terrarium_dimensions_changed.emit(width, height, depth)

@export var height: float = 5.625:
	set(value):
		height = value
		terrarium_dimensions_changed.emit(width, height, depth)

@export var depth: float = 5.625:
	set(value):
		depth = value
		terrarium_dimensions_changed.emit(width, height, depth)

@export var terrarium_dimensions: Vector3 = Vector3(width, height, depth):
	set(value):
		terrarium_dimensions = value
		terrarium_dimensions_changed.emit(width, height, depth)
	get:
		return Vector3(width, height, depth)

# Camera configuration
@export var vertical_fov_deg: float = 45:
	get:
		return vertical_fov_deg
	set(value):
		vertical_fov_deg = value
		fov_changed.emit(value)

@export var aspect_ratio_magic_number: float = 2.52 # 16/9

# Screen configuration
enum Screen {
	SHARED = 1,
	TOP = 2,
	FRONT = 3
}

var shared_screen_layer: int = Screen.SHARED
var top_screen_layer: int = Screen.TOP
var front_screen_layer: int = Screen.FRONT

# Window references
var primary_window: Window
var secondary_window: Window

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
