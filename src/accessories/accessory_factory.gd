extends Node

signal accessory_removed(accessory_data: AccessoryData)
signal accessory_equipped(accessory_data: AccessoryData, creature_data: CreatureData)
signal accessory_unequipped(accessory_data: AccessoryData, creature_data: CreatureData)
signal accessory_added(accessory_data: AccessoryData)

enum AccessoryType {
	HAT
}

enum Accessories {
	TOP_HAT,
	PARTY_HAT,
	CROWN_HAT,
	BUNNY_HAT,
	PIRATE_HAT,
	VIKING_HAT,
	PROPELLER_HAT,
	BEANIE_HAT
}


var accessory_data_templates: Dictionary[Accessories, AccessoryData] = {
	Accessories.TOP_HAT: preload("uid://d0q0xj7jcr5rh"),
	Accessories.PARTY_HAT: preload("uid://ydqcq0aibnrb"),
	Accessories.CROWN_HAT: preload("uid://b2qrw6vn3omma"),
	Accessories.BUNNY_HAT: preload("uid://wcdci50dpenf"),
	Accessories.PIRATE_HAT: preload("uid://dmjykq56j6klc"),
	Accessories.VIKING_HAT: preload("uid://wha8onoswvht"),
	Accessories.PROPELLER_HAT: preload("uid://cgh1yy8jolwdv"),
	Accessories.BEANIE_HAT: preload("uid://db07khs866mm0")
}

## Creates 1 of each accessory type and adds them to the inventory
func create_test_accessories() -> void:
	for accessory in accessory_data_templates:
		for i in range(1):
			var new_accessory = create_accessory(accessory)
			SaveManager.save_file.accessory_inventory.append(new_accessory)

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

func create_accessory_from_data(accessory_data: AccessoryData) -> AccessoryData:
	var new_accessory: AccessoryData = accessory_data.duplicate(true)
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
	creature_data.trigger_preview_update.emit()
	accessory_equipped.emit(accessory_data, creature_data)

func unequip_accessory(accessory_data: AccessoryData, creature_data: CreatureData) -> void:
	accessory_data.accessory_is_equipped = false
	accessory_data.creature_equipped_id = ""
	
	if creature_data.creature_is_in_tank:
		creature_data.creature_instance._apply_accesories()
	creature_data.trigger_preview_update.emit()
	accessory_unequipped.emit(accessory_data, creature_data)

func does_creature_have_any_accessories_equipped(creature_data: CreatureData) -> bool:
	return get_all_equipped_accessories().filter(func(accessory: AccessoryData): return accessory.creature_equipped_id == creature_data.creature_id).size() > 0

func does_creature_have_accessory_equipped(creature_data: CreatureData, accessory_data: AccessoryData) -> bool:
	return get_all_equipped_accessories().filter(func(accessory: AccessoryData): return accessory.creature_equipped_id == creature_data.creature_id and accessory.accessory_category == accessory_data.accessory_category).size() > 0

func sell_accessory(accessory_data: AccessoryData) -> void:
	if accessory_data.accessory_is_equipped:
		unequip_accessory(accessory_data, CreatureFactory.get_creature_by_id(accessory_data.creature_equipped_id))
	SaveManager.save_file.accessory_inventory.erase(accessory_data)
	SaveManager.save_file.money += accessory_data.get_price()
	accessory_removed.emit(accessory_data)
	AudioManager.play_sfx(AudioManager.SFX.COINS_1, 0.8, 1.2)
	VTGlobal.trigger_inventory_refresh.emit()

func unequip_all_accessories(creature_data: CreatureData) -> void:
	for accessory in get_all_accessories_by_creature_id(creature_data.creature_id):
		unequip_accessory(accessory, creature_data)


func add_accessory_to_inventory(accessory_data: AccessoryData) -> void:
	SaveManager.save_file.accessory_inventory.append(accessory_data)
	accessory_added.emit(accessory_data)
