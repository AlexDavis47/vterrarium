extends CharacterBody3D
class_name Creature

## The creature data resource that contains all the common and savable data for the creature.
## We separate this data so that we can save and load creature data easily.
## When we remove a creature, we can just save the creature data and not the entire creature node.
## And when we load a creature, we can just load the saved data back into a new creature instance.
@export var creature_data: CreatureData

func _ready():
	add_to_group("creatures")
	if not creature_data.creature_id:
		creature_data.creature_id = Utils.generate_unique_id()

func get_creature_components() -> Array[CreatureComponent]:
	var creature_components: Array[CreatureComponent] = []
	for child in get_children():
		if child is CreatureComponent:
			creature_components.append(child)
	print("Fish: ", creature_data.creature_name, ": ", creature_components)
	return creature_components

## Called when a new creature is generated
## Luck is used to determine the random stats of the creature
## And this luck is passed down to all the components
func on_generated(luck: float) -> void:
	creature_data.luck = luck
	creature_data.money_rate.base_value *= randfn(luck, 0.25)
	creature_data.creature_id = Utils.generate_unique_id()
	for component in get_creature_components():
		component.on_generated(luck)

func serialize() -> Dictionary:
	var creature_data_dict: Dictionary = creature_data.serialize()
	creature_data_dict["pos_x"] = global_position.x
	creature_data_dict["pos_y"] = global_position.y
	creature_data_dict["pos_z"] = global_position.z
	for component in get_creature_components():
		creature_data_dict[component.name] = component.serialize()
	return creature_data_dict

func deserialize(data: Dictionary):
	creature_data.deserialize(data)
	global_position = Vector3(data["pos_x"], data["pos_y"], data["pos_z"])
	for component in get_creature_components():
		component.deserialize(data[component.name])
