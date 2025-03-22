## This script will receive general input events from the main input system of godot, and map them to the appropriate actions and windows.

extends Node

signal front_window_input(event: InputEvent)
signal top_window_input(event: InputEvent)
signal creature_selected(creature: Node3D, hit_position: Vector3)

var show_debug_markers: bool = false

func _ready():
	VTGlobal.windows_initialized.connect(_on_windows_initialized)

func _on_windows_initialized() -> void:
	VTGlobal.front_window.window_input.connect(_on_front_window_input)
	VTGlobal.top_window.window_input.connect(_on_top_window_input)

	front_window_input.connect(handle_front_window_input)
	top_window_input.connect(handle_top_window_input)

func _on_front_window_input(event: InputEvent) -> void:
	front_window_input.emit(event)

func _on_top_window_input(event: InputEvent) -> void:
	top_window_input.emit(event)

## Cast a ray from camera at the given position
## Returns a dictionary with hit information or null if nothing was hit
func cast_ray_from_camera(camera: Camera3D, screen_position: Vector2, collision_mask: int = 0xFFFFFFFF) -> Dictionary:
	if camera == null:
		return {}
	
	var from = camera.project_ray_origin(screen_position)
	var direction = camera.project_ray_normal(screen_position)
	var to = from + direction * 1000
	
	var space_state = camera.get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = collision_mask
	var result = space_state.intersect_ray(query)
	
	return result if result else {}

## Cast a ray at creatures only (collision layer 2)
func cast_ray_at_creatures(camera: Camera3D, screen_position: Vector2) -> Dictionary:
	return cast_ray_from_camera(camera, screen_position, 2)

## Create a debug sphere at the hit position
func create_hit_marker(position: Vector3, is_creature: bool = false) -> void:
	if not show_debug_markers:
		return
		
	var debug_mesh = MeshInstance3D.new()
	debug_mesh.mesh = SphereMesh.new()
	debug_mesh.mesh.radius = 0.05
	debug_mesh.mesh.height = 0.1

	# Add a timer to the mesh to remove it after a short duration
	var timer = Timer.new()
	timer.wait_time = 1.0
	timer.one_shot = true
	timer.timeout.connect(func(): debug_mesh.queue_free())
	debug_mesh.add_child(timer)
	
	
	var material = StandardMaterial3D.new()
	
	if is_creature:
		material.albedo_color = Color(0, 1, 0) # Green for creatures
	else:
		material.albedo_color = Color(1, 0, 0) # Red for other hits
		
	debug_mesh.material_override = material
	debug_mesh.global_position = position
	get_tree().root.add_child(debug_mesh)
	timer.start()

func handle_front_window_input(event: InputEvent) -> void:
	# Only process mouse events
	if not (event is InputEventMouseButton) or not event.pressed:
		return
		
	var mouse_position = event.position
	
	# First, try to hit creatures
	var creature_hit = cast_ray_at_creatures(VTGlobal.front_camera, mouse_position)
	
	if not creature_hit.is_empty():
		var creature = creature_hit.collider
		var hit_position = creature_hit.position
		
		print("Hit creature: " + str(creature))
		create_hit_marker(hit_position, true)
		creature_selected.emit(creature, hit_position)
		return
	
	# If no creature was hit, try hitting everything
	var hit = cast_ray_from_camera(VTGlobal.front_camera, mouse_position)
	
	if not hit.is_empty():
		print("Front ray hit: " + str(hit.collider) + " at position " + str(hit.position))
		create_hit_marker(hit.position)

func handle_top_window_input(event: InputEvent) -> void:
	# Only process mouse events
	if not (event is InputEventMouseButton) or not event.pressed:
		return
		
	var mouse_position = event.position
	
	# First, try to hit creatures
	var creature_hit = cast_ray_at_creatures(VTGlobal.top_camera, mouse_position)
	
	if not creature_hit.is_empty():
		var creature = creature_hit.collider
		var hit_position = creature_hit.position
		
		print("Hit creature: " + str(creature))
		create_hit_marker(hit_position, true)
		creature_selected.emit(creature, hit_position)
		return
	
	# If no creature was hit, try hitting everything
	var hit = cast_ray_from_camera(VTGlobal.top_camera, mouse_position)
	
	if not hit.is_empty():
		print("Top ray hit: " + str(hit.collider) + " at position " + str(hit.position))
		create_hit_marker(hit.position)

## Public API methods

## Cast a ray from the front camera at the given screen position
## Returns the hit result or an empty dictionary if nothing was hit
func raycast_from_front(screen_position: Vector2, creatures_only: bool = false) -> Dictionary:
	if creatures_only:
		return cast_ray_at_creatures(VTGlobal.front_camera, screen_position)
	else:
		return cast_ray_from_camera(VTGlobal.front_camera, screen_position)

## Cast a ray from the top camera at the given screen position
## Returns the hit result or an empty dictionary if nothing was hit
func raycast_from_top(screen_position: Vector2, creatures_only: bool = false) -> Dictionary:
	if creatures_only:
		return cast_ray_at_creatures(VTGlobal.top_camera, screen_position)
	else:
		return cast_ray_from_camera(VTGlobal.top_camera, screen_position)

## Enable or disable debug markers
func set_debug_markers_visible(visible: bool) -> void:
	show_debug_markers = visible
