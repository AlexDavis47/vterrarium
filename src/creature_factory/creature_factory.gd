## This class is used to generate creatures randomly, and off of creature pools
@tool
extends Node

enum CreaturePool {
	Common,
	Uncommon,
	Rare,
	Legendary
}

# This is all of the creatures the player has in their inventory
# Separate from the creatures in the tank, which are just instances of the creature data
var creature_inventory: Array[CreatureData] = []

## This contains a list of all of the creature data resources that we can duplicate to create new creatures
var creature_data_templates: Array[CreatureData] = [
	preload("uid://c3gof7obhvbej"), # basic crab
	preload("uid://x7f8v6e3a7u2") # basic fish
]

func _ready():
	# Initial setup for testing - create creatures and add to tank
	_create_test_creatures()
	
	# Test cycle 1: Remove all creatures from tank
	await get_tree().create_timer(3.0).timeout
	_remove_all_creatures_from_tank()
	
	# Test cycle 2: Add all creatures back to tank
	await get_tree().create_timer(3.0).timeout
	_add_all_creatures_to_tank()
	
	# Test cycle 3: Remove all creatures from tank again
	await get_tree().create_timer(3.0).timeout
	_remove_all_creatures_from_tank()

	# Test cycle 4: Add all creatures back to tank again
	await get_tree().create_timer(3.0).timeout
	_add_all_creatures_to_tank()

## Creates test creatures and adds them to the inventory and tank
func _create_test_creatures() -> void:
	var creature_name_counter: int = 0
	for creature_data in creature_data_templates:
		for i in range(3):
			var new_creature = _generate_creature_from_template(creature_data)
			new_creature.creature_name = "Test Creature " + str(creature_name_counter)
			creature_inventory.append(new_creature)
			_add_creature_to_tank(new_creature)
			creature_name_counter += 1

## Generates a new creature from a template with random luck
func _generate_creature_from_template(template: CreatureData) -> CreatureData:
	var new_creature = template.duplicate(true)
	new_creature.on_generated(randf_range(0.5, 1.5))
	print(new_creature.serialize())
	return new_creature

## Adds all creatures in inventory to the tank
func _add_all_creatures_to_tank() -> void:
	for creature_data in creature_inventory:
		_add_creature_to_tank(creature_data)
		print(creature_data.serialize())

## Removes all creatures from the tank but keeps them in inventory
func _remove_all_creatures_from_tank() -> void:
	for creature_data in creature_inventory:
		if creature_data.is_in_tank:
			_remove_creature_from_tank(creature_data)

## Adds a creature to the tank
func _add_creature_to_tank(creature_data: CreatureData) -> void:
	var creature = creature_data.creature_scene.instantiate()
	creature.creature_data = creature_data
	creature_data.is_in_tank = true
	creature_data.creature_instance = creature
	add_child(creature)

## Removes a creature from the tank
func _remove_creature_from_tank(creature_data: CreatureData) -> void:
	creature_data.is_in_tank = false
	creature_data.creature_instance.queue_free()
	creature_data.creature_instance = null

## Generates a crab creature and adds it to the tank
func generate_crab() -> void:
	var creature_data = _generate_creature_from_template(creature_data_templates[0])
	_add_creature_to_tank(creature_data)

## Public method to spawn a creature in the tank
func spawn_creature(creature_data: CreatureData) -> void:
	_add_creature_to_tank(creature_data)

## Public method to remove a creature from the tank
func remove_creature(creature: Creature) -> void:
	if creature.creature_data:
		_remove_creature_from_tank(creature.creature_data)
