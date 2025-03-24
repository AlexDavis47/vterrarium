## This class is used to spawn food items in the tank
extends Node

## The default food scene to use if not specified in the food data
@export var default_food_scene: PackedScene

## A list of food data templates that can be used to spawn food
var food_data_templates: Array[FishFoodData] = [
	load("uid://cxcomehb8uap3") # Basic Flakes
]

# For testing, only spawn food if the feeding menu is open
var _feeding_menu_open: bool = false

signal food_spawned(food: FishFood)

func _ready():
	VTInput.top_window_input.connect(_on_top_window_input)

func _on_top_window_input(event: InputEvent) -> void:
	# THIS IS FOR TESTING ONLY
	if event is InputEventScreenTouch and event.pressed and _feeding_menu_open:
		var touch_position = event.position
		var camera = VTGlobal.top_camera
		var world_position = camera.project_position(touch_position, camera.global_position.y - VTConfig.terrarium_dimensions.y / 2)
		print("World position: ", world_position)
		spawn_food(food_data_templates[0], world_position)


## Spawns food in the tank at the specified position with the given food data
func spawn_food(food_data: FishFoodData, position: Vector3, quantity: int = 1) -> Array[FishFood]:
	var spawned_foods: Array[FishFood] = []
	
	# Get the food scene to use
	var food_scene: PackedScene
	if food_data.get_food_scene():
		food_scene = food_data.get_food_scene()
	else:
		food_scene = default_food_scene
	
	if not food_scene:
		push_error("No food scene available for spawning")
		return spawned_foods
	
	# Spawn multiple pieces of food based on quantity
	for i in range(quantity):
		var spawn_pos = _get_spawn_position(position, food_data, i, quantity)
		var food = _create_food_instance(food_data, food_scene, spawn_pos)
		if food:
			spawned_foods.append(food)
			food_spawned.emit(food)
	
	return spawned_foods

## Spawns food by type name
func spawn_food_by_type(food_type_name: String, position: Vector3, quantity: int = 1) -> Array[FishFood]:
	for template in food_data_templates:
		if template.food_name == food_type_name:
			return spawn_food(template, position, quantity)
	
	push_error("No food template found with name: " + food_type_name)
	return []

## Creates randomized spawn positions around the target position
func _get_spawn_position(base_position: Vector3, food_data: FishFoodData, index: int, total: int) -> Vector3:
	var spread = food_data.spread_factor
	
	# For single food items, no spread
	if total == 1:
		return base_position
	
	# For multiple items, spread them out
	var angle = (2 * PI / total) * index
	var radius = randf_range(0.0, spread)
	
	var offset = Vector3(
		cos(angle) * radius,
		randf_range(-0.1, 0.1) * spread, # Slight vertical randomization
		sin(angle) * radius
	)
	
	return base_position + offset

## Creates a food instance from the food data and scene
func _create_food_instance(food_data: FishFoodData, food_scene: PackedScene, position: Vector3) -> FishFood:
	var food_instance = food_scene.instantiate() as FishFood
	if not food_instance:
		push_error("Failed to instantiate food scene")
		return null
	
	# Setup the food with its data
	food_instance.fish_food_data = food_data.duplicate(true)
	food_instance.global_position = position
	
	# Set physical properties based on food data
	food_instance.mass = food_data.food_mass
	
	# Add the food to the tank
	add_child(food_instance)
	
	return food_instance

## Clears all food from the tank
func clear_all_food() -> void:
	for food in get_tree().get_nodes_in_group("fish_food"):
		if food is FishFood:
			food.queue_free()
