## This resource represents the data for a single creature in the creature factory
## It should include things like the creature to be spawned, the pool chances, and any other data
extends Resource
class_name CreatureFactoryData

## The creature to be spawned
@export var creature: PackedScene
## The pool chances for the creature
@export var pool_chances: Array[PoolChance]
