## This node just serializes the crab, deletes the crab, creates a new one, and deserializes the data back into the new crab
extends Node

@export var crab: Creature
@export var crab_scene: PackedScene

func _ready():
	var crabs: Array[Creature] = []
	for i in range(10000):
		var crab = crab_scene.instantiate()
		
		# Ensure each crab has unique creature_data
		if crab.creature_data:
			crab.creature_data = crab.creature_data.duplicate(true)
			
		# Also ensure age component has unique data
		var age_component = crab.get_node_or_null("CreatureAgeComponent")
		if age_component and age_component.creature_age_data:
			age_component.creature_age_data = age_component.creature_age_data.duplicate()
		
		crabs.append(crab)
		# Now safely set unique name
		crab.creature_data.creature_name = "Crab " + str(i)

	while true:
		await get_tree().create_timer(0.1).timeout
		# Select a random crab and add it to the scene
		var crab = crabs[randi() % crabs.size()]
		add_child(crab)
