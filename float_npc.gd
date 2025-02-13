extends CharacterBody3D

@export var speed: float = 0.5
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
		randf_range(-VTConfig.width / 2, VTConfig.width / 2),
		randf_range(-VTConfig.height / 2, VTConfig.height / 2),
		randf_range(-VTConfig.depth / 2, VTConfig.depth / 2)
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
