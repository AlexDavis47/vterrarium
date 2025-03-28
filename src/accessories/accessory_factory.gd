extends Node


enum AccessoryType {
	HAT
}

enum Accessories {
	TOP_HAT,
	PARTY_HAT
}


var accessory_data_templates: Dictionary[Accessories, AccessoryData] = {
	Accessories.TOP_HAT: preload("uid://d0q0xj7jcr5rh"),
	Accessories.PARTY_HAT: preload("uid://ydqcq0aibnrb")
}

## Creates 5 of each accessory type and adds them to the inventory
func create_test_accessories() -> void:
	# Create 5 top hats
	for i in range(5):
		var top_hat = create_accessory(Accessories.TOP_HAT)
		SaveManager.save_file.accessory_inventory.append(top_hat)
	
	# Create 5 party hats
	for i in range(5):
		var party_hat = create_accessory(Accessories.PARTY_HAT)
		SaveManager.save_file.accessory_inventory.append(party_hat)


func get_accessory_by_id(id: String) -> AccessoryData:
	for accessory in SaveManager.save_file.accessory_inventory:
		if accessory.accessory_id == id:
			return accessory
	return null

func get_all_accessories() -> Array[AccessoryData]:
	return SaveManager.save_file.accessory_inventory

func get_all_equipped_accessories() -> Array[AccessoryData]:
	return SaveManager.save_file.accessory_inventory.filter(func(accessory: AccessoryData): return accessory.is_equipped())

func get_all_unequipped_accessories() -> Array[AccessoryData]:
	return SaveManager.save_file.accessory_inventory.filter(func(accessory: AccessoryData): return !accessory.is_equipped())

func get_all_accessories_by_creature_id(creature_id: String) -> Array[AccessoryData]:
	return SaveManager.save_file.accessory_inventory.filter(func(accessory: AccessoryData): return accessory.get_creature_id() == creature_id)

func create_accessory(accessory_type: Accessories) -> AccessoryData:
	var template = accessory_data_templates[accessory_type]
	var new_accessory: AccessoryData = template.duplicate(true)
	new_accessory.on_generated(randf_range(0.5, 1.5))
	return new_accessory

func instantiate_accessory(accessory_data: AccessoryData) -> Node3D:
	var accessory_scene = load(accessory_data.accessory_scene_uuid)
	var accessory = accessory_scene.instantiate()
	return accessory

func equip_accessory(accessory_data: AccessoryData, creature_data: CreatureData) -> void:
	# Remove any existing accessories of the same type
	for accessory in get_all_accessories_by_creature_id(creature_data.creature_id):
		if accessory.accessory_category == accessory_data.accessory_category:
			unequip_accessory(accessory, creature_data)

	accessory_data.accessory_is_equipped = true
	accessory_data.creature_equipped_id = creature_data.creature_id


	# Apply the accessory to the creature
	if creature_data.creature_is_in_tank:
		creature_data.creature_instance._apply_accesories()

func unequip_accessory(accessory_data: AccessoryData, creature_data: CreatureData) -> void:
	accessory_data.accessory_is_equipped = false
	accessory_data.creature_equipped_id = ""
	if creature_data.creature_is_in_tank:
		creature_data.creature_instance._apply_accesories()
