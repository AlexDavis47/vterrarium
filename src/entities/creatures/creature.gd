extends CharacterBody3D
class_name Creature

## The creature data resource that contains all the common and savable data for the creature.
## We separate this data so that we can save and load creature data easily.
## When we remove a creature, we can just save the creature data and not the entire creature node.
## And when we load a creature, we can just load the saved data back into a new creature instance.
@export var creature_data: CreatureData

func _ready():
	add_to_group("creature")
	if not creature_data.creature_id:
		creature_data.creature_id = Utils.generate_unique_id()


func get_creature_components() -> Array[CreatureComponent]:
	var creature_components: Array[CreatureComponent] = []
	for child in get_children():
		if child is CreatureComponent:
			creature_components.append(child)
	return creature_components


func serialize() -> Dictionary:
	var creature_data_dict: Dictionary = creature_data.serialize()
	for component in get_creature_components():
		creature_data_dict[component.name] = component.serialize()
	return creature_data_dict


func deserialize(data: Dictionary):
	creature_data.deserialize(data)
	for component in get_creature_components():
		component.deserialize(data[component.name])
