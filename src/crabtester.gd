## This node just serializes the crab, deletes the crab, creates a new one, and deserializes the data back into the new crab
extends Node

func _ready():
	var crab = CreatureFactory.generate_creature_from_pool(CreatureFactory.CreaturePool.COMMON, randfn(1.0, 0.25))
	add_child(crab)
