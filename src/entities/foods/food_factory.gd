## This class is used to spawn food items in the tank
extends Node

## Enum defining the different types of food available.
## Add new food types here.
enum FoodType {
	BASIC_FLAKES,
	PREMIUM_PELLETS
	# Add more food enum values here
}

## The default food scene to use if not specified in the food data
@export var default_food_scene: PackedScene

## Dictionary mapping FoodType enum to preloaded FishFoodData resources.
var food_data_templates: Dictionary[FoodType, FishFoodData] = {
	FoodType.BASIC_FLAKES: preload("uid://cxcomehb8uap3"),
	FoodType.PREMIUM_PELLETS: preload("uid://cxcomehb8uap3"),
	# Add more food types and their UIDs here, matching the FoodType enum
}

signal food_spawned(food: FishFood)


func _ready() -> void:
	await get_tree().create_timer(1.0).timeout
	for food_type in FoodType.values():
		# Spawn a test food item
		var food_data = food_data_templates[food_type]
		spawn_food(food_data, Vector3(0, 0, 0))

## Spawns food in the tank at the specified position with the given food data
func spawn_food(food_data: FishFoodData, position: Vector3) -> Array[FishFood]:
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
	
	# Spawn multiple pieces of food based on quantity from data
	var quantity = food_data.spawn_quantity
	for i in range(quantity):
		var spawn_pos = _get_spawn_position(position, food_data, i, quantity)
		var food = _create_food_instance(food_data, food_scene, spawn_pos)
		if food:
			spawned_foods.append(food)
			food_spawned.emit(food)
	
	return spawned_foods

## Spawns food by type enum
func spawn_food_by_type(food_type: FoodType, position: Vector3) -> Array[FishFood]:
	if food_data_templates.has(food_type):
		var template: FishFoodData = food_data_templates[food_type]
		return spawn_food(template, position)

	push_error("No food template found for type: %s" % FoodType.keys()[food_type])
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
