## This node just serializes the crab, deletes the crab, creates a new one, and deserializes the data back into the new crab
extends Node


func _ready():
	handle_save_load()
	var crab1 = CreatureFactory.generate_creature_from_type(CreatureFactory.CreatureTemplate.BASIC_CRAB)
	add_child(crab1)
	var crab2 = CreatureFactory.generate_creature_from_type(CreatureFactory.CreatureTemplate.COOLER_CRAB)
	add_child(crab2)
	var fish = CreatureFactory.generate_creature_from_type(CreatureFactory.CreatureTemplate.BASIC_FISH)
	add_child(fish)


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
		var creature_type = data[creature_id].get("creature_type")
		var creature = CreatureFactory.generate_creature_from_type(CreatureFactory.CreatureTemplate.values()[creature_type])
		add_child(creature)
		creature.deserialize(data[creature_id])
