extends TextureRect
class_name AccessoriesContainer

@export var card_container: HFlowContainer
var creature_data: CreatureData # Passed in from the parent

var card_scene: PackedScene = preload("uid://dpj42nvvwygow")

signal accessory_equipped(accessory_data: AccessoryData, creature_data: CreatureData)
signal accessory_unequipped(accessory_data: AccessoryData, creature_data: CreatureData)

func update_ui() -> void:
	for child in card_container.get_children():
		child.queue_free()

	for accessory in SaveManager.save_file.accessory_inventory:
		# If equipped to a different creature, don't show it
		if accessory.accessory_is_equipped and not accessory.creature_equipped_id == creature_data.creature_id:
			continue

		# Create a new card
		var card = card_scene.instantiate()
		card.accessory_data = accessory
		card.creature_data = creature_data
		card.update_ui()
		card_container.add_child(card)

		card.accessory_equipped.connect(_on_accessory_equipped)
		card.accessory_unequipped.connect(_on_accessory_unequipped)
		card.request_update.connect(_on_request_update)

func _on_request_update() -> void:
	update_ui()

func _on_accessory_equipped(accessory_data: AccessoryData, creature_data: CreatureData) -> void:
	accessory_equipped.emit(accessory_data, creature_data)

func _on_accessory_unequipped(accessory_data: AccessoryData, creature_data: CreatureData) -> void:
	accessory_unequipped.emit(accessory_data, creature_data)
