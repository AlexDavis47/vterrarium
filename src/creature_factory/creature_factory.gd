## This class is used to generate creatures randomly, and off of creature pools
@tool
extends Node

enum CreaturePool {
	Common,
	Uncommon,
	Rare,
	Legendary
}

## This contains a list of all of the creature data resources that we can duplicate to create new creatures
var creature_data_templates: Array[CreatureData] = [
	preload("uid://c3gof7obhvbej"), # basic crab
	preload("uid://x7f8v6e3a7u2") # basic fish
]

func _ready():
	for creature_data in creature_data_templates:
		for i in range(3):
			var new_creature = creature_data.duplicate(true)
			new_creature.on_generated(randf_range(0.5, 1.5))
			print(new_creature.serialize())
			var creature = creature_data.creature_scene.instantiate()
			creature.creature_data = new_creature
			add_child(creature)
