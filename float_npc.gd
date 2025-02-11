extends CharacterBody3D

@export var bounds_min: Vector3 = Vector3(-5, -5, -5)
@export var bounds_max: Vector3 = Vector3(5, 5, 5)
@export var speed: float = 2.0
@export var sprite1: Sprite3D
@export var sprite2: Sprite3D

var target_position: Vector3

func _ready():
	randomize()
	randomize_color()
	pick_new_target()

func _process(delta):
	move_towards_target(delta)

func pick_new_target():
	target_position = Vector3(
		randf_range(bounds_min.x, bounds_max.x),
		randf_range(bounds_min.y, bounds_max.y),
		randf_range(bounds_min.z, bounds_max.z)
	)

func move_towards_target(delta):
	var direction = (target_position - global_transform.origin).normalized()
	velocity = direction * speed
	if global_transform.origin.distance_to(target_position) < 0.5:
		pick_new_target()
	move_and_slide()

func randomize_color():
	var new_color = Color(randf(), randf(), randf(), 1.0)
	if sprite1:
		sprite1.modulate = new_color
	if sprite2:
		sprite2.modulate = new_color
