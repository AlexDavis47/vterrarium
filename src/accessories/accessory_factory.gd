extends Node


enum AccessoryType {
	HAT
}

enum Accessories {
	TOP_HAT
}


var accessory_data_templates: Dictionary[Accessories, AccessoryData] = {
	Accessories.TOP_HAT: preload("uid://d0q0xj7jcr5rh")
}

func create_test_top_hat() -> void:
	var top_hat = create_accessory(Accessories.TOP_HAT)
	SaveManager.save_file.accessory_inventory.append(top_hat)
	call_deferred("apply_test_top_hat")

## This is super hacky, but it's just a temporary solution to test the accessory system
func apply_test_top_hat() -> void:
	var top_hat = get_accessory_by_id(SaveManager.save_file.accessory_inventory[0].accessory_id)
	var creature: CreatureData = SaveManager.save_file.creature_inventory[0]
	top_hat.accessory_is_equipped = true
	top_hat.creature_equipped_id = creature.creature_id
	creature.creature_instance._apply_accesories()

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
