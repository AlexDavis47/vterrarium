extends Node3D

## This global script handles 3D touch input by casting a ray from the active camera,
## detecting the collision point in the scene (using a physics raycast), and then
## updating circle nodes accordingly.

## - File names: snake_case (vt_input.gd)

func _input(event: InputEvent) -> void:
	print(event)
	if event is InputEventScreenTouch:
		print("Touch at position: ", event.position)
		var world_pos = screen_to_world(event.position)
	elif event is InputEventScreenDrag:
		var i: int = event.index
		print("Screen drag at position: ", event.position)
		var world_pos = screen_to_world(event.position)
		
	elif event is InputEventScreenTouch and not event.pressed:
		var i: int = event.index
		

## Converts a screen position (2D) to a world position (3D) by casting a ray
## using the active camera.
##
## @param screen_pos The 2D screen coordinate.
## @return The 3D world position of the collision, or the ray origin if no collision.
func screen_to_world(screen_pos: Vector2) -> Vector3:
	# Get the world-space ray origin from the screen position.
	var from: Vector3 = VTGlobal.top_camera.project_ray_origin(screen_pos)
	# Get the world-space ray direction.
	var ray_direction: Vector3 = VTGlobal.top_camera.project_ray_normal(screen_pos)
	var distance: float = 1000.0  # Extend ray far enough; adjust as needed.
	var to: Vector3 = from + ray_direction * distance

	# Create the raycast query.
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	# Only consider objects on collision layer 1 (collision mask value 2 corresponds to bit 1 if 0-indexed)
	query.collision_mask = 2

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var ray_result: Dictionary = space_state.intersect_ray(query)

	if ray_result.has("position"):
		print("Ray collided with: ", ray_result["collider"])
		#var mesh = MeshInstance3D.new()
		#mesh.mesh = SphereMesh.new()
		#mesh.global_position = ray_result["position"]
		#get_tree().root.add_child(mesh)
		
		return ray_result["position"]
	else:
		return from
