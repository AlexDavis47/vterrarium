extends Camera3D
class_name CreatureLiveCamera

@export var creature_data: CreatureData

var creature_instance: Creature

# Constants
const MIN_VERTICAL_ANGLE: float = -89.0
const MAX_VERTICAL_ANGLE: float = 89.0
const CAMERA_DISTANCE_MULTIPLIER: float = 2.0
const DEFAULT_BBOX_SIZE: float = 0.4
const DEFAULT_BBOX_OFFSET: float = -0.2
const SMOOTHING_FACTOR: float = 0.1 # Lower = smoother but slower to respond

# Camera settings
var camera_angle: Vector3 = Vector3(15.0, 0.0, 0.0)
var camera_zoom: float = 0.5
var camera_fov: float = 35.0
var camera_offset: Vector3 = Vector3.ZERO

# Smoothing variables
var _current_bounds: AABB
var _target_bounds: AABB
var _is_first_frame: bool = true

func _ready() -> void:
	if creature_data and creature_data.creature_is_in_tank:
		creature_instance = creature_data.creature_instance

func _process(_delta: float) -> void:
	if creature_data and creature_data.creature_is_in_tank:
		if creature_instance:
			position_camera()
		else:
			creature_instance = creature_data.creature_instance

func position_camera() -> void:
	if not creature_instance:
		return
	
	# Calculate new target bounds
	_target_bounds = _calculate_spatial_bounds(creature_instance, false)
	
	# Initialize current bounds on first frame
	if _is_first_frame:
		_current_bounds = _target_bounds
		_is_first_frame = false
	
	# Smoothly interpolate between current and target bounds
	_current_bounds = _smooth_bounds(_current_bounds, _target_bounds)
	
	var camera_position := _calculate_camera_position(_current_bounds)
	_update_camera_transform(camera_position, _current_bounds)

func _smooth_bounds(current: AABB, target: AABB) -> AABB:
	var smoothed := AABB()
	
	# Smoothly interpolate position
	smoothed.position = current.position.lerp(target.position, SMOOTHING_FACTOR)
	
	# Smoothly interpolate size
	smoothed.size = current.size.lerp(target.size, SMOOTHING_FACTOR)
	
	return smoothed

func _calculate_camera_position(aabb: AABB) -> Vector3:
	var bbox_center := aabb.position + (aabb.size * 0.5)
	var bbox_max_size: float = max(max(aabb.size.x, aabb.size.y), aabb.size.z)
	var distance: float = bbox_max_size * CAMERA_DISTANCE_MULTIPLIER * camera_zoom
	
	var angle_rad := camera_angle * PI / 180.0
	return bbox_center + Vector3(
		cos(angle_rad.x) * cos(angle_rad.y),
		sin(angle_rad.x),
		cos(angle_rad.x) * sin(angle_rad.y)
	) * distance + camera_offset

func _update_camera_transform(camera_position: Vector3, aabb: AABB) -> void:
	var bbox_center := aabb.position + (aabb.size * 0.5)
	global_position = camera_position
	look_at(bbox_center + camera_offset)
	fov = camera_fov

func _calculate_spatial_bounds(parent: Node3D, exclude_top_level_transform: bool) -> AABB:
	var bounds := AABB()
	
	if parent is VisualInstance3D:
		bounds = parent.get_aabb()
	
	for child in parent.get_children():
		if child is Node3D:
			var child_bounds := _calculate_spatial_bounds(child, false)
			if bounds.size == Vector3.ZERO and parent:
				bounds = child_bounds
			else:
				bounds = bounds.merge(child_bounds)
	
	if bounds.size == Vector3.ZERO:
		bounds = AABB(
			Vector3(DEFAULT_BBOX_OFFSET, DEFAULT_BBOX_OFFSET, DEFAULT_BBOX_OFFSET),
			Vector3(DEFAULT_BBOX_SIZE, DEFAULT_BBOX_SIZE, DEFAULT_BBOX_SIZE)
		)
	
	if not exclude_top_level_transform:
		bounds = parent.transform * bounds
	
	return bounds
