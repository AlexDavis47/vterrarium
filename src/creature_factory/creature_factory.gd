## This class is used to generate creatures randomly, and off of creature pools
@tool
extends Node

enum CreaturePool {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY
}

enum CreatureTemplate {
	BASIC_CRAB
}

var creature_templates: Dictionary = {
	CreatureTemplate.BASIC_CRAB: preload("res://src/creature_data/basic_crab.tres")
}


## Generate a creature based on it with optional luck modifier
# We receive a creature data resource, like a basic crab, and we create a duplicate of it
func generate_creature_from_data(creature_data: CreatureData, luck: float = 1.0) -> Creature:
	var new_creature_data = creature_data.duplicate(true)
	var creature: Creature = new_creature_data.creature_scene.instantiate()
	creature.creature_data = new_creature_data
	creature.on_generated(luck)
	return creature

func generate_creature_from_type(creature_type: CreatureTemplate, luck: float = 1.0) -> Creature:
	return generate_creature_from_data(creature_templates[creature_type], luck)


## Generate a random creature from the specified pool
func generate_creature_from_pool(pool: CreaturePool, luck: float = 1.0) -> Creature:
	# Collect all creatures that belong to this pool
	var pool_entries: Array[Dictionary] = []
	var total_chance: float = 0.0
	
	# Iterate through all creature templates to find those with this pool
	for template_key in creature_templates:
		var creature_data: CreatureData = creature_templates[template_key]
		for pool_chance in creature_data.pool_chances:
			if pool_chance.pool == pool:
				pool_entries.append({
					"creature_data": creature_data,
					"chance": pool_chance.chance
				})
				total_chance += pool_chance.chance
	
	if pool_entries.is_empty() or total_chance <= 0:
		push_error("No creatures found for pool %s" % pool)
		return null
	
	# Weighted random selection
	var random_value = randf() * total_chance
	var current_sum = 0.0
	
	for entry in pool_entries:
		current_sum += entry.chance
		if random_value <= current_sum:
			return generate_creature_from_data(entry.creature_data, luck)
	
	# Fallback for floating point errors
	return generate_creature_from_data(pool_entries[0].creature_data, luck)

func _ready():
	await get_tree().create_timer(3.0).timeout
	var test = generate_creature_from_data(creature_templates[CreatureTemplate.BASIC_CRAB], 1)
	print("Test creature:")
	print(test.serialize())

	var test2 = generate_creature_from_pool(CreaturePool.COMMON, 1)
	print("Test creature 1 from pool:")
	print(test2.serialize())

	var test3 = generate_creature_from_pool(CreaturePool.COMMON, 1)
	print("Test creature 2 from pool:")
	print(test3.serialize())
