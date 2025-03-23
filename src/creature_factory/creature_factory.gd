## This class is used to generate creatures randomly, and off of creature pools
@tool
extends Node

enum CreaturePool {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY
}

## This contains a list of all of the creature data resources that we can duplicate to create new creatures
## Stored mainly for scanning pools
var creature_data_templates: Array[CreatureData] = [
	preload("uid://c3gof7obhvbej"), # basic crab
	preload("uid://x7f8v6e3a7u2") # basic fish
]

# Since we're no longer using scene UUIDs to spawn the correct creature scene,
# we use an Enum of types to determine which creature to spawn
# and then apply the correct creature data to the creature instance

enum CreatureType {
	FISH,
	CRAB
}

## Map of creature type to creature scene
## When a creature data is spawned, check the creature type
## to instantiate the correct scene and apply the creature data to the instance
var creature_type_to_data: Dictionary = {
	CreatureType.FISH: preload("uid://bpq3hl6lq1ngy"), # fish
	CreatureType.CRAB: preload("uid://dlwv2lwgphc3e") # crab
}


signal creature_spawned(creature_data: CreatureData)
signal creature_removed(creature_data: CreatureData)


func run_test_cycle() -> void:
		# Initial setup for testing - create creatures and add to tank
	_create_test_creatures()
	
	# Test cycle 1: Remove all creatures from tank
	await get_tree().create_timer(1.0).timeout
	_remove_all_creatures_from_tank()
	
	# Test cycle 2: Add all creatures back to tank
	await get_tree().create_timer(1.0).timeout
	_add_all_creatures_to_tank()
	
	# Test cycle 3: Remove all creatures from tank again
	await get_tree().create_timer(1.0).timeout
	_remove_all_creatures_from_tank()

	# Test cycle 4: Add all creatures back to tank again
	await get_tree().create_timer(1.0).timeout
	_add_all_creatures_to_tank()


## Creates test creatures and adds them to the inventory and tank
func _create_test_creatures() -> void:
	for creature_data in creature_data_templates:
		for i in range(3):
			var new_creature = _generate_creature_from_template(creature_data)
			SaveManager.save_file.creature_inventory.append(new_creature)
			_add_creature_to_tank(new_creature)

## Generates a new creature from a template with random luck
func _generate_creature_from_template(template: CreatureData) -> CreatureData:
	var new_creature: CreatureData = template.duplicate(true)
	new_creature.on_generated(randf_range(0.5, 1.5))
	return new_creature

## Adds all creatures in inventory to the tank
func _add_all_creatures_to_tank() -> void:
	for creature_data in SaveManager.save_file.creature_inventory:
		_add_creature_to_tank(creature_data)

## Removes all creatures from the tank but keeps them in inventory
func _remove_all_creatures_from_tank() -> void:
	for creature_data in SaveManager.save_file.creature_inventory:
		if creature_data.creature_is_in_tank:
			_remove_creature_from_tank(creature_data)

## Adds a creature to the tank
func _add_creature_to_tank(creature_data: CreatureData) -> void:
	var creature_scene = creature_type_to_data[creature_data.creature_type]
	var creature = creature_scene.instantiate()
	creature.creature_data = creature_data
	creature_data.creature_is_in_tank = true
	creature_data.creature_instance = creature
	add_child(creature)

## Removes a creature from the tank
func _remove_creature_from_tank(creature_data: CreatureData) -> void:
	creature_data.creature_is_in_tank = false
	creature_data.creature_instance.queue_free()
	creature_data.creature_instance = null

## Public method to spawn a creature in the tank
func spawn_creature(creature_data: CreatureData) -> void:
	_add_creature_to_tank(creature_data)
	creature_spawned.emit(creature_data)
	Utils.play_sfx(preload("uid://cqlml5h7eycko"), 0.8, 1.2)

## Public method to remove a creature from the tank
func remove_creature(creature: Creature) -> void:
	if creature.creature_data:
		_remove_creature_from_tank(creature.creature_data)
		creature_removed.emit(creature.creature_data)
		
func remove_creature_by_data(creature_data: CreatureData) -> void:
	_remove_creature_from_tank(creature_data)
	creature_removed.emit(creature_data)


func _generate_creature_from_pool(pool: CreaturePool) -> CreatureData:
	var viable_creatures: Array[CreatureData] = []
	for creature_data in creature_data_templates:
		for pool_chance in creature_data.creature_pool_chances:
			if pool_chance.pool == pool:
				viable_creatures.append(creature_data)

	var total_chance: float = 0.0
	for creature_data in viable_creatures:
		total_chance += creature_data.creature_pool_chances[pool].chance


	var random_value: float = randf_range(0.0, total_chance)
	var cumulative_chance: float = 0.0
	for creature_data in viable_creatures:
		cumulative_chance += creature_data.creature_pool_chances[pool].chance
		if random_value <= cumulative_chance:
			return creature_data

	return null
