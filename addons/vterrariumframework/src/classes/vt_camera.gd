extends Camera3D
class_name VTCamera3D

enum CameraPosition {
	TOP,
	FRONT
}

@export var camera_orientation: CameraPosition = CameraPosition.TOP:
	set(value):
		camera_orientation = value
		setup_camera_position()

func _ready() -> void:
	# Set FOV to match hardware camera
	fov = VTConfig.vertical_fov_deg
	
	# Connect to configuration changes
	VTConfig.fov_changed.connect(_on_fov_changed)
	VTConfig.terrarium_dimensions_changed.connect(_on_box_dimensions_changed)
	
	# Initial setup
	setup_camera_position()

func _process(delta: float) -> void:
	setup_camera_position()

func _on_fov_changed(new_fov: float) -> void:
	fov = new_fov
	setup_camera_position()

func _on_box_dimensions_changed(_width: float, _height: float, _depth: float) -> void:
	setup_camera_position()

## Our "dolly zoom" formula: distance = (height/2)/tan(FOV/2) + depth/2
## This formula will give us the distance the camera needs to be from the center of the box
## to perfectly fit the box in the view.
func _calculate_dolly_distance(fov_deg: float, height: float, depth: float) -> float:

	var fov_rad := deg_to_rad(fov_deg)
	
	# Calculate distance using our derived formula
	return (height / 2.0) / tan(fov_rad / 2.0) + depth / 2.0

func setup_camera_position() -> void:
	

	match camera_orientation:
		CameraPosition.TOP:
			var distance := _calculate_dolly_distance(VTConfig.vertical_fov_deg, VTConfig.depth, VTConfig.height)
			# Position camera above looking down
			transform.origin = Vector3(0, distance, 0)
			rotation_degrees = Vector3(-90, 0, 0)

		CameraPosition.FRONT:
			var distance := _calculate_dolly_distance(VTConfig.vertical_fov_deg, VTConfig.height, VTConfig.depth)
			# Position camera in front looking forward
			transform.origin = Vector3(0, 0, distance)
			rotation_degrees = Vector3(0, 0, 0)
