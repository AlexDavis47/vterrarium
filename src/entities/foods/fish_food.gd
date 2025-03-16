## A food item that can be eaten by creatures.
## Specifics about the food are determined by fish_food_data resources.
@tool
extends RigidBody3D
class_name FishFood

## The multiplier for using the viscosity of the liquid/gas of the VTerrarium.
## Since the viscosity of water is around 0.5, applying the viscosity itself would be far too powerful.
const VISCOSITY_MULTIPLIER = 0.99


signal food_eaten(food: FishFood)
signal food_gone(food: FishFood)

@export var fish_food_data: FishFoodData
@export var eaten_particles: CPUParticles3D
@export var food_mesh: MeshInstance3D

var is_edible: bool = true

func _ready():
	add_to_group("fish_food")


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
	fish_food_data.times_eatable -= 1
	_burst_particles()
	if fish_food_data.times_eatable <= 0:
		print("Freeing food")
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
