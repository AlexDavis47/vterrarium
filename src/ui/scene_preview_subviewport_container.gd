@tool
extends SubViewportContainer
class_name ScenePreviewSubviewportContainer

# Export variables grouped by functionality
@export_group("Scene Components")
@export var preview_camera: Camera3D
@export var subviewport: SubViewport
@export var root_node: Node3D

@export_group("Camera Settings")
@export var camera_angle: Vector3 = Vector3(45.0, 45.0, 0.0)
@export var camera_zoom: float = 1.0
@export var camera_fov: float = 75.0
@export var camera_offset: Vector3 = Vector3.ZERO

@export_group("GeneralSettings")
## If enabled, dragging on the preview will rotate the camera
@export var drag_enabled: bool = false
## The sensitivity of the camera rotation
@export var drag_sensitivity: float = 5.0
## If enabled, the preview will update continuously, otherwise it will only update when dragged, or when force_update is called
@export var continuous_update: bool = false
## If enabled, the viewport background will be transparent
@export var transparent_background: bool = false

# Constants
const MIN_VERTICAL_ANGLE: float = -89.0
const MAX_VERTICAL_ANGLE: float = 89.0
const DRAG_ROTATION_FACTOR: float = 0.1
const DEFAULT_BBOX_SIZE: float = 0.4
const DEFAULT_BBOX_OFFSET: float = -0.2
const CAMERA_DISTANCE_MULTIPLIER: float = 2.0

# Private variables
var _dragging: bool = false
var _last_mouse_pos: Vector2 = Vector2.ZERO

# Built-in functions
func _ready() -> void:
	position_camera()
	await get_tree().process_frame
	force_update()
	if transparent_background:
		subviewport.transparent_bg = true

func _process(_delta: float) -> void:
	if continuous_update or _dragging:
		force_update()

func _gui_input(event: InputEvent) -> void:
	if not drag_enabled:
		return
	
	if event is InputEventScreenTouch:
		_handle_touch_input(event)
	elif event is InputEventScreenDrag and _dragging:
		_handle_drag_input(event)

# Public functions
func force_update() -> void:
	position_camera()
	subviewport.render_target_update_mode = SubViewport.UPDATE_ONCE

func clear_root_node() -> void:
	for child in root_node.get_children():
		child.queue_free()

func add_child_to_root_node(child: Node3D) -> void:
	root_node.add_child(child)
	child.process_mode = Node.PROCESS_MODE_DISABLED

# Camera positioning
func position_camera() -> void:
	if not _are_components_valid():
		return
	
	var aabb := _calculate_spatial_bounds(root_node, false)
	var camera_position := _calculate_camera_position(aabb)
	
	_update_camera_transform(camera_position, aabb)

# Private helper functions
func _handle_touch_input(event: InputEventScreenTouch) -> void:
	_dragging = event.pressed
	_last_mouse_pos = event.position

func _handle_drag_input(event: InputEventScreenDrag) -> void:
	var delta := event.position - _last_mouse_pos
	_last_mouse_pos = event.position
	
	_update_camera_angles(delta)
	position_camera()

func _update_camera_angles(delta: Vector2) -> void:
	camera_angle.y += delta.x * drag_sensitivity * DRAG_ROTATION_FACTOR
	camera_angle.x = clamp(
		camera_angle.x + delta.y * drag_sensitivity * DRAG_ROTATION_FACTOR,
		MIN_VERTICAL_ANGLE,
		MAX_VERTICAL_ANGLE
	)

func _are_components_valid() -> bool:
	return root_node and preview_camera and root_node.get_children()

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
	preview_camera.position = camera_position
	preview_camera.look_at(bbox_center + camera_offset)
	preview_camera.fov = camera_fov

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
