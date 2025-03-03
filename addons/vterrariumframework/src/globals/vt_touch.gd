extends Node3D
class_name VTTouch3D

## VTTouch3D
## This global script handles 3D touch input by casting a ray from the active camera,
## detecting the collision point in the scene (using a physics raycast), and then
## updating circle nodes accordingly.
##
## Node and file naming follow the style guidelines:
## - Class names: PascalCase (VTTouch3D)
## - File names: snake_case (vt_touch_3d.gd)

@onready var circle_container: Node = $CircleContainer
@onready var camera: Camera3D = get_viewport().get_camera_3d()  # Get the active camera
var circles: Array[Node3D] = []

func _ready() -> void:
	## Initialize circles.
	for circle in circle_container.get_children():
		circle.hide()
		circles.append(circle)

func _input(event: InputEvent) -> void:
	print(event)
	if event is InputEventScreenDrag:
		var i: int = event.index
		print("Screen drag at position: ", event.position)
		if i >= 0 and i < circles.size():
			var world_pos: Vector3 = screen_to_world(event.position)
			circles[i].show()
			circles[i].global_transform.origin = world_pos  # Set 3D position
	elif event is InputEventScreenTouch and not event.pressed:
		var i: int = event.index
		if i >= 0 and i < circles.size():
			circles[i].hide()

## Converts a screen position (2D) to a world position (3D) by casting a ray
## using the active camera.
##
## @param screen_pos The 2D screen coordinate.
## @return The 3D world position of the collision, or the ray origin if no collision.
func screen_to_world(screen_pos: Vector2) -> Vector3:
	var from: Vector3 = camera.project_ray_origin(screen_pos)
	var ray_direction: Vector3 = camera.project_ray_normal(screen_pos)
	var distance: float = 1000.0  # Extend ray far enough; adjust as needed.
	var to: Vector3 = from + ray_direction * distance

	# Create the raycast query.
	var query: PhysicsRayQueryParameters3D = PhysicsRayQueryParameters3D.create(from, to)
	# Only consider objects on collision layer 1.
	# (Note: collision mask value of 2 corresponds to bit 1 if layers are 0-indexed.
	# Adjust this value according to your project's collision layer configuration.)
	query.collision_mask = 2

	var space_state: PhysicsDirectSpaceState3D = get_world_3d().direct_space_state
	var ray_result: Dictionary = space_state.intersect_ray(query)

	if ray_result.has("position"):
		print("Ray collided with: ", ray_result["collider"])
		return ray_result["position"]
	else:
		return from
