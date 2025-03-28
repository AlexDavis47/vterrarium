## This class is used to generate creatures randomly, and off of creature pools
@tool
extends Node

enum CreaturePool {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY
}

enum CreatureType {
	FISH,
	CRAB
}

enum Creatures {
	BLUE_FISH,
	RED_FISH,
	YELLOW_TANG_FISH
}


## This contains a list of all of the creature data resources that we can duplicate to create new creatures
## Stored mainly for scanning pools
var creature_data_templates: Dictionary[Creatures, CreatureData] = {
	Creatures.BLUE_FISH: preload("uid://bi10nf3pilsau"),
	Creatures.RED_FISH: preload("uid://x7f8v6e3a7u2"),
	Creatures.YELLOW_TANG_FISH: preload("uid://cl4iqwjh3g3cm")
}

signal creature_spawned(creature_data: CreatureData)
signal creature_removed(creature_data: CreatureData)


func run_test_cycle() -> void:
		# Initial setup for testing - create creatures and add to tank
	_create_test_creatures()
	
	# # Test cycle 1: Remove all creatures from tank
	# await get_tree().create_timer(1.0).timeout
	# _remove_all_creatures_from_tank()
	
	# # Test cycle 2: Add all creatures back to tank
	# await get_tree().create_timer(1.0).timeout
	# _add_all_creatures_to_tank()
	
	# # Test cycle 3: Remove all creatures from tank again
	# await get_tree().create_timer(1.0).timeout
	# _remove_all_creatures_from_tank()

	# # Test cycle 4: Add all creatures back to tank again
	# await get_tree().create_timer(1.0).timeout
	# _add_all_creatures_to_tank()


## Creates test creatures and adds them to the inventory and tank
func _create_test_creatures() -> void:
	for creature_type in creature_data_templates.keys():
		for i in range(10):
			var new_creature = create_creature(creature_type)
			SaveManager.save_file.creature_inventory.append(new_creature)
			_add_creature_to_tank(new_creature)

## Creates a new creature of the specified type with random luck
func create_creature(creature_type: Creatures) -> CreatureData:
	var template = creature_data_templates[creature_type]
	var new_creature: CreatureData = template.duplicate(true)
	new_creature.on_generated(randf_range(0.5, 1.5))
	return new_creature

## Generates a new creature from a template with random luck
## @deprecated Use create_creature instead
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
	var creature_scene = load(creature_data.creature_scene_uuid)
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
	var viable_creatures: Array[Creatures] = []
	var viable_chances: Dictionary = {}
	
	for creature_type in creature_data_templates.keys():
		var template = creature_data_templates[creature_type]
		for pool_chance in template.creature_pool_chances:
			if pool_chance.pool == pool:
				viable_creatures.append(creature_type)
				viable_chances[creature_type] = pool_chance.chance

	var total_chance: float = 0.0
	for creature_type in viable_creatures:
		total_chance += viable_chances[creature_type]

	var random_value: float = randf_range(0.0, total_chance)
	var cumulative_chance: float = 0.0
	
	for creature_type in viable_creatures:
		cumulative_chance += viable_chances[creature_type]
		if random_value <= cumulative_chance:
			return create_creature(creature_type)

	return null


func get_creature_by_id(id: String) -> CreatureData:
	for creature in SaveManager.save_file.creature_inventory:
		if creature.creature_id == id:
			return creature
	return null

func get_creature_instance_by_id(id: String) -> Creature:
	for creature in get_tree().get_nodes_in_group("creatures"):
		if creature.creature_data.creature_id == id:
			return creature
	return null


func create_creature_preview(creature_data: CreatureData) -> Creature:
	var creature_scene = load(creature_data.creature_scene_uuid)
	var creature = creature_scene.instantiate()
	creature.creature_data = creature_data
	creature._is_in_preview_mode = true
	creature.process_mode = PROCESS_MODE_DISABLED
	return creature
