extends Creature
var target_position: Vector3

func _ready() -> void:
	super()
	target_position = _pick_random_position()
	
	
func _physics_process(delta: float) -> void:
	super(delta)
	
	# Age data access
	if creature_data.age_data:
		print(creature_data.age_data.get_age())
	
	# Movement handling
	velocity.y -= 5 * delta
	move_and_slide()
	if is_on_floor():
		velocity.y = 0
		
	# Use the speed from the speed data component
	var speed = 0.2
	if creature_data and creature_data.speed_data:
		speed = creature_data.speed_data.get_current_speed()
	var direction = (target_position - global_position).normalized()
	velocity += direction * speed
	velocity *= 0.75
	
	var distance = global_position.distance_to(target_position)
	if distance <= 1:
		target_position = _pick_random_position()

func _pick_random_position():
	var x = randf_range(- VTConfig.width / 2, VTConfig.width / 2)
	var y = - VTConfig.height / 2
	var z = randf_range(- VTConfig.depth / 2, VTConfig.depth / 2)
	var position: Vector3 = Vector3(x, y, z)
	return position
