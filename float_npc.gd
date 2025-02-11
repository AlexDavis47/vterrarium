@tool
extends CharacterBody3D

@export var bounds_min: Vector3 = Vector3(-0.254, -0.134, -0.134)
@export var bounds_max: Vector3 = Vector3(0.254, 0.134, 0.134)
@export var speed: float = 0.01
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
		randf_range(bounds_min.x/2, bounds_max.x/2),
		randf_range(bounds_min.y/2, bounds_max.y/2),
		randf_range(bounds_min.z/2, bounds_max.z/2)
	)

func move_towards_target(delta):
	var direction = (target_position - global_transform.origin).normalized()
	velocity = direction * speed
	if global_transform.origin.distance_to(target_position) < 0.01:
		pick_new_target()
	move_and_slide()

func randomize_color():
	var new_color = Color(randf(), randf(), randf(), 1.0)
	if sprite1:
		sprite1.modulate = new_color
	if sprite2:
		sprite2.modulate = new_color
