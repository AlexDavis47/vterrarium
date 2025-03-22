## A food item that can be eaten by creatures.
## Specifics about the food are determined by fish_food_data resources.
extends RigidBody3D
class_name FishFood

## The multiplier for using the viscosity of the liquid/gas of the VTerrarium.
## Since the viscosity of water is around 0.5, applying the viscosity itself would be far too powerful.
const VISCOSITY_MULTIPLIER = 0.99

signal food_eaten(food: FishFood)
signal food_gone(food: FishFood)

# The data resource that defines this food's properties
@export var fish_food_data: FishFoodData
@export var eaten_particles: CPUParticles3D
@export var food_mesh: MeshInstance3D

# Runtime properties
var is_edible: bool = true
var remaining_bites: int = 1
var food_lifetime_timer: SceneTreeTimer = null

func _ready():
	add_to_group("fish_food")
	configure_from_data()

## Configure the food instance based on the data resource
func configure_from_data() -> void:
	if fish_food_data == null:
		push_error("FishFood is missing fish_food_data!")
		return
	
	# Set up the food's appearance
	if food_mesh and food_mesh.mesh:
		var material = food_mesh.mesh.surface_get_material(0) as StandardMaterial3D
		if material:
			material.albedo_color = fish_food_data.food_color
	
	# Initialize food properties
	remaining_bites = fish_food_data.times_eatable
	
	# Start lifetime timer if configured
	if fish_food_data.food_lifetime > 0:
		food_lifetime_timer = get_tree().create_timer(fish_food_data.food_lifetime)
		food_lifetime_timer.timeout.connect(_on_food_lifetime_expired)

func _physics_process(delta: float) -> void:
	apply_viscosity(delta)

## According the the configured viscosity of the liquid/gas of the VTerrarium,
## the food will have friction applied to it, causing it to move slower in the tank.
func apply_viscosity(delta: float) -> void:
	var velocity = linear_velocity
	var viscosity = VTConfig.viscosity
	velocity.x *= viscosity * VISCOSITY_MULTIPLIER
	velocity.y *= viscosity * VISCOSITY_MULTIPLIER
	velocity.z *= viscosity * VISCOSITY_MULTIPLIER
	linear_velocity = velocity

## Eat the food and return true if the food is still edible, false if it is not.
func eat_food() -> void:
	food_eaten.emit(self)
	remaining_bites -= 1
	_burst_particles()
	
	if remaining_bites <= 0:
		_free_food()

func _burst_particles() -> void:
	eaten_particles.emitting = true
	var material = eaten_particles.mesh.surface_get_material(0) as StandardMaterial3D
	material.albedo_color = fish_food_data.food_color
	
func _free_food() -> void:
	is_edible = false
	food_gone.emit(self)
	food_mesh.visible = false
	await get_tree().create_timer(eaten_particles.lifetime).timeout
	queue_free()

func _on_food_lifetime_expired() -> void:
	if is_edible:
		# Food expired naturally
		_free_food()

## Factory method to create food from data
static func create_from_data(food_data: FishFoodData, food_scene: PackedScene) -> FishFood:
	var food_instance = food_scene.instantiate() as FishFood
	if food_instance:
		food_instance.fish_food_data = food_data
	return food_instance
