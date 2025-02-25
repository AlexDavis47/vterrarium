extends Node3D
class_name Touch3D

@onready var circle_container = $circle_container
var camera: Camera3D
var circles = []

func _ready() -> void:
	camera = VTGlobal.top_camera as Camera3D
	for circle in circle_container.get_children():
		circle.hide()
		circles.append(circle)

func _input(event):
	print(event)
	if event is InputEventScreenDrag:
		var i = event.index
		print(event.position)
		if i >= 0 and i < circles.size():
			var world_pos = screen_to_world(event.position)
			circles[i].show()
			circles[i].global_transform.origin = world_pos  # Set 3D position
	elif event is InputEventScreenTouch and not event.pressed:
		var i = event.index
		if i >= 0 and i < circles.size():
			circles[i].hide()

# Convert screen position (2D) to world position (3D)
func screen_to_world(screen_pos: Vector2) -> Vector3:
	var from = camera.project_ray_origin(screen_pos)
	var ray_direction = camera.project_ray_normal(screen_pos)
	var distance = 100
	var to = from + ray_direction * distance
	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.collision_mask = 2
	var space_state = get_world_3d().direct_space_state
	var ray_result = space_state.intersect_ray(query)
	if ray_result.has("position"):
		print("Ray collided with: ", ray_result["collider"])
		return ray_result["position"]
	else:
		return from
