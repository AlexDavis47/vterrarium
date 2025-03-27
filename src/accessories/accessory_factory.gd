extends Node

var accessory_data_templates: Array[AccessoryData] = [

]


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
