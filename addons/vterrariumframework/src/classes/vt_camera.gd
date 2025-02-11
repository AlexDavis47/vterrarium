@tool
extends Camera3D
class_name VTCamera3D

enum CameraPosition {
	TOP,
	FRONT
}

@export var camera_position: CameraPosition = CameraPosition.TOP

func _ready() -> void:
	# Set FOV to match hardware camera
	fov = VTConfig.horizontal_fov_deg
	# Connect to FOV changes
	VTConfig.fov_changed.connect(_on_fov_changed)
	
	setup_camera_position()

func _process(delta: float) -> void:
	setup_camera_position()

func _on_fov_changed(new_fov: float) -> void:
	fov = new_fov
	setup_camera_position() # Update camera position since FOV affects distance calculation

func setup_camera_position() -> void:
	# Calculate distance using the formula: d = w / (2.68 * tan(θ/2))
	var fov_rad := deg_to_rad(VTConfig.horizontal_fov_deg)
	# Use height value since it's actually our width
	var distance: float = VTConfig.height / (VTConfig.aspect_ratio_magic_number * tan(fov_rad / 2))
	
	match camera_position:
		CameraPosition.TOP:
			# Position camera above looking down
			transform.origin = Vector3(0, distance, 0)
			rotation_degrees = Vector3(-90, 0, 0)
			print("Top camera transform: ", transform)
			
		CameraPosition.FRONT:
			# Position camera in front looking forward
			transform.origin = Vector3(0, 0, distance)
			rotation_degrees = Vector3(0, 0, 0)
			print("Front camera transform: ", transform)
