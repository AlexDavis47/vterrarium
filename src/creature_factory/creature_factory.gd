## This class is used to generate creatures randomly, and off of creature pools
extends Node

enum CreaturePool {
	COMMON,
	UNCOMMON,
	RARE,
	LEGENDARY
}
## The creature factory data contains pool chances for each creature
var creature_list: Dictionary[String, CreatureFactoryData] = {
	"common_crab": preload("res://src/creature_factory/creature_factory_data/common_crab.tres"),
	"uncommon_crab": preload("res://src/creature_factory/creature_factory_data/uncommon_crab.tres"),
	"rare_crab": preload("res://src/creature_factory/creature_factory_data/rare_crab.tres"),
	"legendary_crab": preload("res://src/creature_factory/creature_factory_data/legendary_crab.tres")
}

func generate_creature(creature_factory_data: CreatureFactoryData, luck: float) -> Creature:
	var creature: Creature = creature_factory_data.creature.instantiate()
	creature.on_generated(luck)
	return creature


func generate_creature_from_pool(pool: CreaturePool, luck: float) -> Creature:
	# Select all creatures that have this pool in their pool chances
	var total_pool_chance: float = 0
	var creatures_in_pool: Dictionary[CreatureFactoryData, float] = {}
	
	for creature_factory_data in creature_list.values():
		for pool_chance in creature_factory_data.pool_chances:
			if pool_chance.pool == pool:
				creatures_in_pool[creature_factory_data] = pool_chance.chance
				total_pool_chance += pool_chance.chance
	
	# Implement weighted random selection
	var random_value = randf() * total_pool_chance
	var current_sum = 0.0
	
	for creature_data in creatures_in_pool:
		current_sum += creatures_in_pool[creature_data]
		if random_value <= current_sum:
			return generate_creature(creature_data, luck)
	
	# Fallback in case of floating point errors
	return generate_creature(creatures_in_pool.keys()[0], luck)


func _ready():
	await get_tree().create_timer(3.0).timeout
	var test = generate_creature(creature_list["common_crab"], 1)
	print("Test creature:")
	print(test.serialize())

	var test2 = generate_creature_from_pool(CreaturePool.COMMON, 1)
	print("Test creature 1 from pool:")
	print(test2.serialize())

	var test3 = generate_creature_from_pool(CreaturePool.COMMON, 1)
	print("Test creature 2 from pool:")
	print(test3.serialize())
