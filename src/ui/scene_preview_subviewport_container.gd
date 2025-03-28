@tool
extends SubViewportContainer
class_name ScenePreviewSubviewportContainer

@export var preview_camera: Camera3D
@export var subviewport: SubViewport
@export var root_node: Node3D
@export var camera_angle: Vector3 = Vector3(45.0, 45.0, 0.0)
@export var camera_zoom: float = 1.0 # Multiplier for distance from target
@export var camera_fov: float = 75.0 # Field of view in degrees
@export var camera_offset: Vector3 = Vector3.ZERO # Offset from calculated position
@export var continuous_update: bool = false # Toggle for continuous rendering
@export var drag_enabled: bool = false # Toggle for draggable camera
@export var drag_sensitivity: float = 5.0 # Sensitivity of camera rotation

var _first_update_done: bool = false
var _dragging: bool = false
var _last_mouse_pos: Vector2 = Vector2.ZERO

func _ready():
	position_camera()
	if !continuous_update:
		# Force one update to ensure initial render
		force_update()

func _gui_input(event: InputEvent) -> void:
	if !drag_enabled:
		return
		
	if event is InputEventScreenTouch:
		_dragging = event.pressed
		_last_mouse_pos = event.position
			
	elif event is InputEventScreenDrag and _dragging:
		var delta = event.position - _last_mouse_pos
		_last_mouse_pos = event.position
		
		# Update camera angles based on touch movement
		camera_angle.y += delta.x * drag_sensitivity * 0.1 # Horizontal rotation
		camera_angle.x = clamp(
			camera_angle.x + delta.y * drag_sensitivity * 0.1, # Vertical rotation
			-89.0, # Minimum vertical angle
			89.0 # Maximum vertical angle
		)
		
		# Ensure continuous updates while dragging
		if !continuous_update:
			subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		position_camera()

func _process(_delta: float) -> void:
	if continuous_update or !_first_update_done:
		position_camera()
		_first_update_done = true
		if !continuous_update:
			# Switch to UPDATE_DISABLED after first update
			if !_dragging: # Don't disable updates while dragging
				subviewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

# Force a manual update when needed (e.g., when model changes)
func force_update() -> void:
	_first_update_done = false
	if !continuous_update:
		subviewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		await get_tree().process_frame # For some reason, it takes two frames to update the render target
		await get_tree().process_frame
		subviewport.render_target_update_mode = SubViewport.UPDATE_ONCE

# # Stop dragging if mouse released outside the viewport
# func _notification(what: int) -> void:
# 	if what == NOTIFICATION_MOUSE_EXIT:
# 		_dragging = false
# 		if !continuous_update:
# 			subviewport.render_target_update_mode = SubViewport.UPDATE_DISABLED

func position_camera():
	if !root_node or !preview_camera or !root_node.get_children():
		return
		
	# Calculate AABB (bounding box)
	var aabb = _calculate_spatial_bounds(root_node, true)
	
	# Calculate camera position based on bounding box
	var bbox_center = aabb.position + (aabb.size * 0.5)
	var bbox_max_size = max(max(aabb.size.x, aabb.size.y), aabb.size.z)
	
	# Position camera at an angle from the center
	var distance = bbox_max_size * 2.0 * camera_zoom # Apply zoom factor
	var angle_rad = camera_angle * PI / 180.0
	var camera_pos = bbox_center + Vector3(
		cos(angle_rad.x) * cos(angle_rad.y),
		sin(angle_rad.x),
		cos(angle_rad.x) * sin(angle_rad.y)
	) * distance + camera_offset # Add offset to final position
	
	preview_camera.position = camera_pos
	preview_camera.look_at(bbox_center + camera_offset) # Offset the look_at target too
	preview_camera.fov = camera_fov # Set the camera's field of view

func _calculate_spatial_bounds(parent: Node3D, exclude_top_level_transform: bool) -> AABB:
	var bounds: AABB = AABB()
	if parent is VisualInstance3D:
		bounds = parent.get_aabb()

	for child in parent.get_children():
		if child is Node3D:
			var child_bounds: AABB = _calculate_spatial_bounds(child, false)
			if bounds.size == Vector3.ZERO and parent:
				bounds = child_bounds
			else:
				bounds = bounds.merge(child_bounds)
				
	if bounds.size == Vector3.ZERO and !parent:
		bounds = AABB(Vector3(-0.2, -0.2, -0.2), Vector3(0.4, 0.4, 0.4))
		
	if !exclude_top_level_transform:
		bounds = parent.transform * bounds
		
	return bounds


func clear_root_node() -> void:
	for child in root_node.get_children():
		child.queue_free()

func add_child_to_root_node(child: Node3D) -> void:
	root_node.add_child(child)
