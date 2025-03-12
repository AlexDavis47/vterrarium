## This node just serializes the crab, deletes the crab, creates a new one, and deserializes the data back into the new crab
extends Node

func _ready():
	handle_save_load()
	for i in 2:
		var crab = CreatureFactory.generate_creature_from_pool(CreatureFactory.CreaturePool.COMMON, randfn(1.0, 0.25))
		add_child(crab)
		await get_tree().create_timer(2.0).timeout
	

func handle_save_load() -> void:
	print("Saving...")
	await get_tree().create_timer(10.0).timeout
	var data = {}
	for creature in get_tree().get_nodes_in_group("creatures"):
		data[creature.creature_data.creature_id] = creature.serialize()
		creature.queue_free()

	await get_tree().create_timer(2.0).timeout
	
	# Data is now in serialized form, we need to deserialize it
	for creature_id in data:
		var creature = CreatureFactory.generate_creature_from_creature_type(data[creature_id]["creature_type"], CreatureFactory.CreatureType.COMMON_CRAB)
		add_child(creature)
		creature.deserialize(data[creature_id])
