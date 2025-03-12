## This node just serializes the crab, deletes the crab, creates a new one, and deserializes the data back into the new crab
extends Node

@export var crab: Creature
@export var crab_scene: PackedScene

func _ready():
	crab.creature_data.creature_name = "Original Crab"
	await get_tree().create_timer(5.0).timeout
	var data = crab.serialize()
	crab.queue_free()
	await get_tree().create_timer(2.0).timeout
	crab = crab_scene.instantiate()
	add_child(crab)
	crab.deserialize(data)
	crab.creature_data.creature_name = "Deserialized Crab"
