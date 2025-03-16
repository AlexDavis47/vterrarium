## Helper resource for creature factory data. Helps display the pool chances in the inspector
extends Resource
class_name PoolChance

@export var pool: CreatureFactory.CreaturePool:
	set(value):
		pool = value
	get:
		return pool

@export var chance: float:
	set(value):
		chance = value
	get:
		return chance
